extends Area2D

signal interacted

@export_file("*.dtl") var timeline_path: String
@export var npc_name: String = "NPC"

var _player_in_range: bool = false
var _is_dialogue_active: bool = false

@onready var interact_label: Label = get_node_or_null("InteractLabel")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interact_label:
		interact_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or _is_dialogue_active:
		return

	if event.is_action_pressed("interact"):
		_start_dialogue()
		get_viewport().set_input_as_handled()


func _start_dialogue() -> void:
	if timeline_path.is_empty():
		return

	_is_dialogue_active = true
	if interact_label:
		interact_label.visible = false
	interacted.emit()

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)

	Dialogic.start(timeline_path)
	Dialogic.timeline_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)


func _on_dialogue_ended() -> void:
	_is_dialogue_active = false

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)

	if _player_in_range and interact_label:
		interact_label.visible = true


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if interact_label and not _is_dialogue_active:
			interact_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if interact_label:
			interact_label.visible = false
