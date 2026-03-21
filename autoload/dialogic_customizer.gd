extends Node

## 在 runtime 自訂 Dialogic 對話框外觀（不修改 addon 檔案）
## - 對話框大小根據 viewport 動態計算（寬 3/4、高 1/4）
## - 對話框透明度 50%、人名透明度 55%
## - 人名位置左上角偏移，不擋對話
## - 關閉對話框動畫
## - 字型大小自適應（對話框高度 1/3，文字過長自動縮小）

const BOX_WIDTH_RATIO := 0.75
const BOX_HEIGHT_RATIO := 0.25
const BOX_OPACITY := 0.5
const NAME_LABEL_OPACITY := 0.52
const NAME_LABEL_OFFSET := Vector2(10, -75)
const MIN_FONT_SIZE := 20

var _base_font_size := 0
var _customized := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Dialogic layout 是動態建立的，需要持續監聽
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node.name == "VN_TextboxLayer":
		# 等 Dialogic 完成初始化
		await get_tree().process_frame
		await get_tree().process_frame
		if is_instance_valid(node) and node.is_inside_tree():
			_customize_textbox(node)


func _customize_textbox(layer: Node) -> void:
	var vp_size := layer.get_viewport().get_visible_rect().size

	## ── 對話框大小 ──────────────────────────────────
	var box_w := vp_size.x * BOX_WIDTH_RATIO
	var box_h := vp_size.y * BOX_HEIGHT_RATIO
	var sizer: Control = layer.get_node("%Sizer")
	if sizer:
		sizer.size = Vector2(box_w, box_h)
		sizer.position = Vector2(-box_w * 0.5, -box_h) + Vector2(0, -15)

	## ── 對話框透明度 ──────────────────────────────────
	var dialog_panel: PanelContainer = layer.get_node("%DialogTextPanel")
	if dialog_panel:
		var c := dialog_panel.self_modulate
		dialog_panel.self_modulate = Color(c.r, c.g, c.b, BOX_OPACITY)

	## ── 人名透明度與位置 ──────────────────────────────
	var name_panel: PanelContainer = layer.get_node("%NameLabelPanel")
	if name_panel:
		var nc := name_panel.self_modulate
		name_panel.self_modulate = Color(nc.r, nc.g, nc.b, NAME_LABEL_OPACITY)
		name_panel.position = NAME_LABEL_OFFSET

	## ── 關閉對話框動畫 ──────────────────────────────
	var animations: AnimationPlayer = layer.get_node("%Animations")
	if animations:
		animations.set(&'animation_in', 0)   # NONE
		animations.set(&'animation_out', 0)   # NONE
		animations.set(&'animation_new_text', 0)  # NONE

	## ── 字型大小（對話框高度 1/3）──────────────────────
	_base_font_size = int(box_h / 3.0)
	var dialog_text: RichTextLabel = layer.get_node("%DialogicNode_DialogText")
	if dialog_text:
		_set_all_font_sizes(dialog_text, _base_font_size)
		# 連接自適應
		if not dialog_text.is_connected(&"started_revealing_text", _on_text_revealing):
			dialog_text.connect(&"started_revealing_text", _on_text_revealing.bind(dialog_text, sizer))

	## ── 人名字型大小 ──────────────────────────────────
	var name_label: Label = layer.get_node("%DialogicNode_NameLabel")
	if name_label:
		name_label.add_theme_font_size_override(&"font_size", int(_base_font_size * 0.6))

	_customized = true


## ── 字型自適應 ──────────────────────────────────────

func _on_text_revealing(dialog_text: RichTextLabel, sizer: Control) -> void:
	# 先恢復到基本大小
	_set_all_font_sizes(dialog_text, _base_font_size)
	await get_tree().process_frame
	# 檢查是否超出並縮小
	_auto_fit_text(dialog_text, sizer)


func _auto_fit_text(dialog_text: RichTextLabel, sizer: Control) -> void:
	if not sizer or not dialog_text:
		return
	var available_height := sizer.size.y - 30.0  # 扣除 padding
	var current_size := _base_font_size

	while dialog_text.get_content_height() > available_height and current_size > MIN_FONT_SIZE:
		current_size -= 2
		_set_all_font_sizes(dialog_text, current_size)
		await get_tree().process_frame


func _set_all_font_sizes(dialog_text: RichTextLabel, size: int) -> void:
	dialog_text.add_theme_font_size_override(&"normal_font_size", size)
	dialog_text.add_theme_font_size_override(&"bold_font_size", size)
	dialog_text.add_theme_font_size_override(&"italics_font_size", size)
	dialog_text.add_theme_font_size_override(&"bold_italics_font_size", size)


## ── 供 ESC 選單呼叫的公開方法 ──────────────────────

func get_current_font_size() -> int:
	return _base_font_size


func set_font_size(size: int) -> void:
	_base_font_size = size
	for node in get_tree().get_nodes_in_group("dialogic_dialog_text"):
		_set_all_font_sizes(node, size)


func set_box_opacity(alpha: float) -> void:
	for node in get_tree().get_nodes_in_group("dialogic_layout_layer"):
		var panel: PanelContainer = node.get_node_or_null("%DialogTextPanel")
		if panel:
			var c := panel.self_modulate
			panel.self_modulate = Color(c.r, c.g, c.b, alpha)
