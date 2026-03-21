extends Node

signal entry_added(entry: Dictionary)

const MAX_ENTRIES := 200

var entries: Array[Dictionary] = []


func log_event(category: String, message: String, data: Dictionary = {}) -> void:
	var entry := {
		"time": Time.get_datetime_string_from_system(),
		"category": category,
		"message": message,
		"data": data.duplicate(true),
	}
	entries.append(entry)
	if entries.size() > MAX_ENTRIES:
		entries.pop_front()

	var suffix := ""
	if not data.is_empty():
		suffix = " %s" % JSON.stringify(data)
	print("[Flow][%s] %s%s" % [category, message, suffix])
	entry_added.emit(entry)


func clear() -> void:
	entries.clear()
