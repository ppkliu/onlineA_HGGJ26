extends Node

## Replaces Dialogic's built-in Audio subsystem at runtime without modifying
## the plugin files inside addons/.

const FIXED_AUDIO_SUBSYSTEM := preload("res://autoload/dialogic_audio_subsystem_fixed.gd")
const MAX_INSTALL_ATTEMPTS := 16


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_install_hotfix")


func _install_hotfix(attempt: int = 0) -> void:
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic == null or not is_instance_valid(dialogic):
		if attempt < MAX_INSTALL_ATTEMPTS:
			await get_tree().process_frame
			_install_hotfix(attempt + 1)
		else:
			push_warning("DialogicAudioHotfix could not find /root/Dialogic.")
		return

	var current_audio := dialogic.get_node_or_null("Audio")
	if current_audio == null:
		if attempt < MAX_INSTALL_ATTEMPTS:
			await get_tree().process_frame
			_install_hotfix(attempt + 1)
		else:
			push_warning("DialogicAudioHotfix could not find Dialogic Audio subsystem.")
		return

	if current_audio.get_script() == FIXED_AUDIO_SUBSYSTEM:
		return

	var preserved_audio_state: Dictionary = dialogic.current_state_info.get("audio", {}).duplicate(true)

	dialogic.remove_child(current_audio)
	current_audio.queue_free()

	var replacement := FIXED_AUDIO_SUBSYSTEM.new()
	replacement.name = "Audio"
	replacement.dialogic = dialogic
	dialogic.add_child(replacement)
	replacement.post_install()

	if not preserved_audio_state.is_empty():
		await get_tree().process_frame
		dialogic.current_state_info["audio"] = preserved_audio_state
		replacement.load_game_state()
