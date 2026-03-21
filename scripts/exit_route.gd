extends Resource
class_name ExitRoute

func _init(
	route_exit_name: StringName = &"Exit1",
	route_scene_path: String = "",
	route_spawn_point: StringName = &"SpawnPoint_Right",
	route_transition_type: int = 0
) -> void:
	exit_name = route_exit_name
	scene_path = route_scene_path
	spawn_point = route_spawn_point
	transition_type = route_transition_type


@export var exit_name: StringName = &"Exit1"
@export_file("*.tscn") var scene_path: String
@export var spawn_point: StringName = &"SpawnPoint_Right"
@export_enum("Fade Black", "Loop Restart", "Death") var transition_type: int = 0
