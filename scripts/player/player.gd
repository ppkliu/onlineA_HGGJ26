extends CharacterBody2D

@export var speed: float = 300.0
var can_move: bool = true
var last_horizontal_facing: int = 1

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func set_can_move(value: bool) -> void:
	can_move = value
	if not value:
		velocity = Vector2.ZERO
		_play_animation("idle")


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	_update_animation(direction)
	move_and_slide()


func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		_update_sprite_flip()
		_play_animation("idle")
		return

	if direction.x < 0.0:
		last_horizontal_facing = -1
	elif direction.x > 0.0:
		last_horizontal_facing = 1

	_update_sprite_flip()

	if last_horizontal_facing < 0:
		_play_animation("walk_left")
	else:
		_play_animation("walk_right")


func _play_animation(animation_name: StringName) -> void:
	if animated_sprite != null and animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation(animation_name):
			if animated_sprite.animation != animation_name:
				animated_sprite.play(animation_name)
			elif not animated_sprite.is_playing():
				animated_sprite.play()
			return


func _update_sprite_flip() -> void:
	if animated_sprite != null:
		animated_sprite.flip_h = last_horizontal_facing > 0
	elif sprite != null:
		sprite.flip_h = last_horizontal_facing < 0
