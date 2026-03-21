extends CanvasLayer

enum TransitionType {
	FADE_BLACK,         # 一般場景切換
	LOOP_RESTART,       # 輪迴重啟（特殊動畫）
	DEATH,              # 死亡轉場
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

signal transition_midpoint  # 轉場中點（可在此切換場景）


func transition_to(scene_path: String, type: TransitionType = TransitionType.FADE_BLACK) -> void:
	match type:
		TransitionType.FADE_BLACK:
			animation_player.play("fade_out")
		TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_out")
		TransitionType.DEATH:
			animation_player.play("death_fade")

	await animation_player.animation_finished
	transition_midpoint.emit()

	get_tree().change_scene_to_file(scene_path)

	match type:
		TransitionType.FADE_BLACK:
			animation_player.play("fade_in")
		TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_in")
		TransitionType.DEATH:
			animation_player.play("death_reveal")

	await animation_player.animation_finished
