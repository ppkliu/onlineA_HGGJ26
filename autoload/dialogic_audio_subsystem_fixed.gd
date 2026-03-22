extends "res://addons/dialogic/Modules/Audio/subsystem_audio.gd"

## Project-local hotfix for Dialogic audio fades.
## Avoids MethodTweener + bound-argument type issues in Godot 4.6 by
## tweening volume_db directly instead of tween_method() with a bound node.

const MIN_FADE_DB := -80.0


func update_audio(channel_name:= "", path := "", settings_overrides := {}) -> void:
	if not is_channel_playing(channel_name) and path.is_empty():
		return

	var audio_settings: Dictionary = DialogicUtil.get_audio_channel_defaults().get(channel_name, {})
	audio_settings.merge(
		{"volume": 0, "audio_bus": "", "fade_length": 0.0, "loop": true, "sync_channel": ""}
	)
	audio_settings.merge(settings_overrides, true)

	if is_channel_playing(channel_name):
		var prev_audio_node: AudioStreamPlayer = current_audio_channels[channel_name]
		prev_audio_node.name += "_Prev"
		if audio_settings.fade_length > 0.0:
			var fade_out_tween: Tween = create_tween()
			fade_out_tween.tween_property(prev_audio_node, "volume_db", MIN_FADE_DB, audio_settings.fade_length)
			fade_out_tween.tween_callback(prev_audio_node.queue_free)
		else:
			prev_audio_node.queue_free()

	if not dialogic.current_state_info.has("audio"):
		dialogic.current_state_info["audio"] = {}

	if not path:
		dialogic.current_state_info["audio"].erase(channel_name)
		return

	dialogic.current_state_info["audio"][channel_name] = {"path": path, "settings_overrides": settings_overrides}
	audio_started.emit(dialogic.current_state_info["audio"][channel_name])

	var new_player := AudioStreamPlayer.new()
	if channel_name:
		new_player.name = channel_name.validate_node_name()
		audio_node.add_child(new_player)
	else:
		new_player.name = "OneShotSFX"
		one_shot_audio_node.add_child(new_player)

	var file := load(path)
	if file == null:
		printerr("[Dialogic] Audio file \"%s\" failed to load." % path)
		return

	new_player.stream = file

	if audio_settings.fade_length > 0.0:
		new_player.volume_db = MIN_FADE_DB
		var fade_in_tween := create_tween()
		fade_in_tween.tween_property(new_player, "volume_db", float(audio_settings.volume), audio_settings.fade_length)
	else:
		new_player.volume_db = audio_settings.volume

	new_player.bus = audio_settings.audio_bus

	if "loop" in new_player.stream:
		new_player.stream.loop = audio_settings.loop
	elif "loop_mode" in new_player.stream:
		if audio_settings.loop:
			new_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			new_player.stream.loop_begin = 0
			new_player.stream.loop_end = new_player.stream.mix_rate * new_player.stream.get_length()
		else:
			new_player.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED

	if audio_settings.sync_channel and is_channel_playing(audio_settings.sync_channel):
		var play_position: float = current_audio_channels[audio_settings.sync_channel].get_playback_position()
		new_player.play(play_position)

		if new_player.stream is AudioStreamWAV and new_player.stream.format == AudioStreamWAV.FORMAT_IMA_ADPCM:
			printerr("[Dialogic] WAV files using Ima-ADPCM compression cannot be synced. Reimport the file using a different compression mode.")
			dialogic.print_debug_moment()
	else:
		new_player.play()

	new_player.finished.connect(_on_audio_finished.bind(new_player, channel_name, path))

	if channel_name:
		current_audio_channels[channel_name] = new_player
