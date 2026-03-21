extends Area2D

@export_file("*.tscn") var next_scene_path: String
@export var target_spawn_point: StringName
@export_enum("Fade Black", "Loop Restart", "Death") var transition_type: int = 0


func _ready() -> void:
	monitoring = not next_scene_path.is_empty()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if SceneTransition.is_transitioning():
		return

	if next_scene_path.is_empty():
		push_warning("%s has no next_scene_path configured." % name)
		return

	if body.has_method("set_can_move"):
		body.call("set_can_move", false)

	SceneTransition.transition_to(next_scene_path, transition_type, target_spawn_point)


func configure_route(scene_path: String, spawn_point_name: StringName, next_transition_type: int) -> void:
	next_scene_path = scene_path
	target_spawn_point = spawn_point_name
	transition_type = next_transition_type
	monitoring = not next_scene_path.is_empty()
