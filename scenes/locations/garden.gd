extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var background: Sprite2D = $Background


func _ready() -> void:
	_fit_background_to_viewport()
	player.set_can_move(true)


func _fit_background_to_viewport() -> void:
	if background == null or background.texture == null:
		return
	var tex_size := background.texture.get_size()
	if tex_size.x <= 0 or tex_size.y <= 0:
		return
	var vp_size := get_viewport_rect().size
	var scale_factor := maxf(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
	background.scale = Vector2(scale_factor, scale_factor)
	background.position = vp_size / 2.0
