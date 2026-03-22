extends Node

## 在 runtime 自訂 Dialogic 對話框外觀（不修改 addon 檔案）
## - 對話框大小根據 viewport 動態計算（寬 3/4、高 1/4）
## - 對話框透明度提高，並加上邊框
## - 人名位置左上角偏移，不擋對話
## - 關閉對話框動畫
## - 字型大小自適應（對話框高度 1/3，文字過長自動縮小）

const BOX_WIDTH_RATIO := 0.76
const BOX_HEIGHT_RATIO := 0.22
const BOX_OPACITY := 0.88
const NAME_LABEL_OPACITY := 0.92
const NAME_OPACITY_RATIO := NAME_LABEL_OPACITY / BOX_OPACITY
const NAME_LABEL_OFFSET := Vector2(18, -64)
const MIN_FONT_SIZE := 18
const DIALOG_BORDER_COLOR := Color(0.95, 0.88, 0.68, 1.0)
const DIALOG_BORDER_WIDTH := 3
const DIALOG_PANEL_PADDING_LEFT := 32.0
const DIALOG_PANEL_PADDING_TOP := 22.0
const DIALOG_PANEL_PADDING_RIGHT := 22.0
const DIALOG_PANEL_PADDING_BOTTOM := 22.0
const NAME_PANEL_PADDING_X := 14.0
const NAME_PANEL_PADDING_Y := 8.0
const CUSTOM_LAYOUT_GROUP := "dialogic_layout_layer"

var _base_font_size := 0
var _customized := false
var _current_box_opacity := BOX_OPACITY
var _current_name_opacity := NAME_LABEL_OPACITY


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
	layer.add_to_group(CUSTOM_LAYOUT_GROUP)

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
		_apply_bordered_style(dialog_panel, Color(c.r, c.g, c.b, _current_box_opacity))

	## ── 人名透明度與位置 ──────────────────────────────
	var name_panel: PanelContainer = layer.get_node("%NameLabelPanel")
	if name_panel:
		var nc := name_panel.self_modulate
		_apply_bordered_style(name_panel, Color(nc.r, nc.g, nc.b, _current_name_opacity))
		name_panel.position = NAME_LABEL_OFFSET

	## ── 關閉對話框動畫 ──────────────────────────────
	var animations: AnimationPlayer = layer.get_node("%Animations")
	if animations:
		animations.set(&'animation_in', 0)   # NONE
		animations.set(&'animation_out', 0)   # NONE
		animations.set(&'animation_new_text', 0)  # NONE

	## ── 字型大小（對話框高度 1/3）──────────────────────
	_base_font_size = int(box_h / 4.0)
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


func _apply_bordered_style(panel: PanelContainer, bg_color: Color) -> void:
	var stylebox := panel.get_theme_stylebox(&"panel")
	if stylebox is StyleBoxFlat:
		var flat := (stylebox as StyleBoxFlat).duplicate() as StyleBoxFlat
		flat.bg_color = bg_color
		flat.content_margin_left = DIALOG_PANEL_PADDING_LEFT
		flat.content_margin_top = DIALOG_PANEL_PADDING_TOP
		flat.content_margin_right = DIALOG_PANEL_PADDING_RIGHT
		flat.content_margin_bottom = DIALOG_PANEL_PADDING_BOTTOM
		flat.border_width_left = DIALOG_BORDER_WIDTH
		flat.border_width_top = DIALOG_BORDER_WIDTH
		flat.border_width_right = DIALOG_BORDER_WIDTH
		flat.border_width_bottom = DIALOG_BORDER_WIDTH
		flat.border_color = DIALOG_BORDER_COLOR
		flat.corner_radius_top_left = 8
		flat.corner_radius_top_right = 8
		flat.corner_radius_bottom_right = 8
		flat.corner_radius_bottom_left = 8
		if panel.name == "NameLabelPanel":
			flat.content_margin_left = NAME_PANEL_PADDING_X
			flat.content_margin_top = NAME_PANEL_PADDING_Y
			flat.content_margin_right = NAME_PANEL_PADDING_X
			flat.content_margin_bottom = NAME_PANEL_PADDING_Y
		panel.add_theme_stylebox_override(&"panel", flat)
		panel.self_modulate = Color(1, 1, 1, 1)


## ── 供 ESC 選單呼叫的公開方法 ──────────────────────

func get_current_font_size() -> int:
	return _base_font_size


func get_current_box_opacity() -> float:
	return _current_box_opacity


func set_font_size(size: int) -> void:
	_base_font_size = size
	for node in get_tree().get_nodes_in_group("dialogic_dialog_text"):
		_set_all_font_sizes(node, size)


func set_box_opacity(alpha: float) -> void:
	_current_box_opacity = clampf(alpha, 0.0, 1.0)
	_current_name_opacity = clampf(_current_box_opacity * NAME_OPACITY_RATIO, 0.0, 1.0)

	for node in get_tree().get_nodes_in_group(CUSTOM_LAYOUT_GROUP):
		var dialog_panel: PanelContainer = node.get_node_or_null("%DialogTextPanel")
		if dialog_panel:
			_update_panel_background_alpha(dialog_panel, _current_box_opacity)

		var name_panel: PanelContainer = node.get_node_or_null("%NameLabelPanel")
		if name_panel:
			_update_panel_background_alpha(name_panel, _current_name_opacity)


func _update_panel_background_alpha(panel: PanelContainer, alpha: float) -> void:
	var stylebox := panel.get_theme_stylebox(&"panel")
	if stylebox is StyleBoxFlat:
		var flat := (stylebox as StyleBoxFlat).duplicate() as StyleBoxFlat
		flat.bg_color = Color(flat.bg_color.r, flat.bg_color.g, flat.bg_color.b, alpha)
		panel.add_theme_stylebox_override(&"panel", flat)
	else:
		var c := panel.self_modulate
		panel.self_modulate = Color(c.r, c.g, c.b, alpha)
