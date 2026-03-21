extends CanvasLayer

const TransitionType = TransitionConstants.TransitionType

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

signal transition_midpoint  # 轉場中點（可在此切換場景）


func transition_to(scene_path: String, type: TransitionConstants.TransitionType = TransitionConstants.TransitionType.FADE_BLACK) -> void:
	FlowLogger.log_event("scene", "Start transition", {"scene_path": scene_path, "type": TransitionConstants.TransitionType.keys()[type]})
	match type:
		TransitionConstants.TransitionType.FADE_BLACK:
			animation_player.play("fade_out")
		TransitionConstants.TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_out")
		TransitionConstants.TransitionType.DEATH:
			animation_player.play("death_fade")

	await animation_player.animation_finished
	transition_midpoint.emit()

	get_tree().change_scene_to_file(scene_path)
	FlowLogger.log_event("scene", "Changed scene", {"scene_path": scene_path})

	match type:
		TransitionConstants.TransitionType.FADE_BLACK:
			animation_player.play("fade_in")
		TransitionConstants.TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_in")
		TransitionConstants.TransitionType.DEATH:
			animation_player.play("death_reveal")

	await animation_player.animation_finished
	FlowLogger.log_event("scene", "Transition finished", {"scene_path": scene_path})
