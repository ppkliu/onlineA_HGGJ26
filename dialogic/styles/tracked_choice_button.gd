class_name TrackedChoiceButton
extends DialogicNode_ChoiceButton

## Custom choice button that tracks visited choices and shows a visual indicator.

var _visited_color := Color(0.6, 0.6, 0.7, 1.0)
var _unvisited_color := Color(1.0, 1.0, 1.0, 1.0)
var _visited_prefix := "✓ "
var _tracking_key: String = ""


func _load_info(choice_info: Dictionary) -> void:
	super(choice_info)

	var raw_text: String = choice_info.get("text", "")
	_tracking_key = IntelSystem.make_choice_tracking_key(choice_info)
	var is_visited: bool = IntelSystem.is_choice_visited(_tracking_key)

	if is_visited:
		set_choice_text(_visited_prefix + raw_text)
		add_theme_color_override("font_color", _visited_color)
		add_theme_color_override("font_hover_color", _visited_color)
		add_theme_color_override("font_focus_color", _visited_color)
	else:
		add_theme_color_override("font_color", _unvisited_color)
		remove_theme_color_override("font_hover_color")
		remove_theme_color_override("font_focus_color")


func _pressed() -> void:
	IntelSystem.mark_choice_visited(_tracking_key)
	super()
