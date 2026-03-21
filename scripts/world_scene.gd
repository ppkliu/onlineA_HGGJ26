extends Node2D

@export var default_spawn_point: StringName = &"SpawnPoint_Default"
@export var exit_routes: Array[ExitRoute] = []


func _ready() -> void:
	_configure_exit_routes()
	call_deferred("_finish_scene_setup")


func _configure_exit_routes() -> void:
	for child in get_children():
		if child != null and child.has_method("configure_route"):
			child.call("configure_route", "", StringName(), 0)

	for route in exit_routes:
		if route == null:
			continue

		var exit_zone := find_child(String(route.exit_name), true, false)
		if exit_zone == null or not exit_zone.has_method("configure_route"):
			push_warning("Exit route node not found or invalid: %s" % String(route.exit_name))
			continue

		exit_zone.call(
			"configure_route",
			route.scene_path,
			route.spawn_point,
			route.transition_type
		)


func _finish_scene_setup() -> void:
	var player = find_child("Player", true, false)
	if player == null:
		return

	var spawn_point_name := SceneTransition.consume_target_spawn_point()
	if spawn_point_name == StringName():
		spawn_point_name = default_spawn_point

	var spawn_point := find_child(String(spawn_point_name), true, false) as Marker2D
	if spawn_point != null:
		player.global_position = spawn_point.global_position

	if player.has_method("set_can_move"):
		player.call("set_can_move", false)

	if SceneTransition.is_transitioning():
		await SceneTransition.transition_finished

	if player.has_method("set_can_move"):
		player.call("set_can_move", true)
