extends CanvasLayer

const TransitionType = TransitionConstants.TransitionType

signal transition_midpoint
signal transition_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

var target_spawn_point: StringName = &""
var _is_transitioning: bool = false


func transition_to(
	scene_path: String,
	type: TransitionConstants.TransitionType = TransitionConstants.TransitionType.FADE_BLACK,
	spawn_point_name: StringName = &""
) -> void:
	if _is_transitioning:
		return

	if scene_path.is_empty():
		push_warning("SceneTransition.transition_to called with an empty scene path.")
		return

	_is_transitioning = true
	target_spawn_point = spawn_point_name
	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

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

	await get_tree().process_frame

	match type:
		TransitionConstants.TransitionType.FADE_BLACK:
			animation_player.play("fade_in")
		TransitionConstants.TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_in")
		TransitionConstants.TransitionType.DEATH:
			animation_player.play("death_reveal")

	await animation_player.animation_finished
	FlowLogger.log_event("scene", "Transition finished", {"scene_path": scene_path})
