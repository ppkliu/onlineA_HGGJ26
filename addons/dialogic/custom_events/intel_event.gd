extends DialogicEvent
class_name DialogicIntelEvent

## Dialogic 自訂事件 — 在時間線中觸發情報獲取

var intel_id: String = ""


func _execute() -> void:
	IntelSystem.acquire_intel(intel_id)
	finish()


func _init() -> void:
	event_name = "Intel Acquire"
	set_default_color(Color(0.2, 0.8, 0.4))


func _get_as_text() -> String:
	return "[intel %s]" % intel_id


func _from_text(string: String) -> void:
	var regex = RegEx.new()
	regex.compile("\\[intel (?P<id>.+)\\]")
	var result = regex.search(string)
	if result:
		intel_id = result.get_string("id")


func _is_valid_event(string: String) -> bool:
	return string.begins_with("[intel")
