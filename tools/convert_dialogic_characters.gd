@tool
extends SceneTree

const DEFAULT_CHARACTER_DIR := "res://dialogic/characters"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var check_only := args.has("--check")
	var paths := _collect_target_paths(args)

	if paths.is_empty():
		push_error("No .dch files found to process.")
		quit(1)
		return

	var converted := 0
	var skipped := 0
	var failed := 0

	for path in paths:
		var result := _process_character_file(path, check_only)
		match result:
			"converted":
				converted += 1
			"skipped":
				skipped += 1
			_:
				failed += 1

	print("Dialogic character conversion finished.")
	print("  converted: %d" % converted)
	print("  skipped: %d" % skipped)
	print("  failed: %d" % failed)

	quit(1 if failed > 0 else 0)


func _collect_target_paths(args: Array) -> Array[String]:
	var targets: Array[String] = []

	for arg in args:
		if arg.begins_with("--"):
			continue

		if arg.ends_with(".dch"):
			targets.append(ProjectSettings.globalize_path(arg if arg.begins_with("res://") else "res://" + arg.trim_prefix("./")))

	if not targets.is_empty():
		return _normalize_paths(targets)

	var dir := DirAccess.open(DEFAULT_CHARACTER_DIR)
	if dir == null:
		return []

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".dch"):
			targets.append(ProjectSettings.globalize_path(DEFAULT_CHARACTER_DIR.path_join(file_name)))
		file_name = dir.get_next()

	return _normalize_paths(targets)


func _normalize_paths(paths: Array[String]) -> Array[String]:
	var normalized: Array[String] = []
	var seen := {}

	for path in paths:
		var localized := ProjectSettings.localize_path(path)
		if localized.is_empty() or seen.has(localized):
			continue
		seen[localized] = true
		normalized.append(localized)

	return normalized


func _process_character_file(path: String, check_only: bool) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s" % path)
		return "failed"

	var raw_text := file.get_as_text()
	var parsed = str_to_var(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Failed to parse %s as Dictionary." % path)
		return "failed"

	if _is_dialogic_instance_dict(parsed):
		print("SKIP %s (already uses Dialogic instance format)" % path)
		return "skipped"

	var character := _character_from_simplified_dict(parsed, path)
	if character == null:
		push_error("Failed to build DialogicCharacter from %s" % path)
		return "failed"

	if check_only:
		print("CHECK %s (would convert)" % path)
		return "converted"

	var save_error := ResourceSaver.save(character, path)
	if save_error != OK:
		push_error("Failed to save %s (error %d)" % [path, save_error])
		return "failed"

	print("CONVERT %s" % path)
	return "converted"


func _is_dialogic_instance_dict(data: Dictionary) -> bool:
	if data.has("@subpath") or data.has("@script"):
		return true

	var path_value = data.get("@path", "")
	return path_value is String and str(path_value).ends_with(".gd")


func _character_from_simplified_dict(data: Dictionary, path: String) -> DialogicCharacter:
	var character := DialogicCharacter.new()
	character.take_over_path(path)

	character.display_name = str(data.get("display_name", ""))
	character.nicknames = _to_string_array(data.get("nicknames", []))
	character.description = str(data.get("description", ""))
	character.scale = float(data.get("scale", 1.0))
	character.mirror = bool(data.get("mirror", false))
	character.custom_info = data.get("custom_info", {}).duplicate(true)

	character.color = _parse_variant(data.get("color", Color()), Color())
	character.offset = _parse_variant(data.get("offset", Vector2()), Vector2())
	character.portraits = _parse_portraits(data.get("portraits", {}))

	if data.has("default_portrait"):
		character.default_portrait = str(data.get("default_portrait", ""))
	elif character.portraits.has("default"):
		character.default_portrait = "default"

	return character


func _parse_portraits(portraits_data: Dictionary) -> Dictionary:
	var portraits := {}

	for portrait_name in portraits_data.keys():
		var portrait: Variant = portraits_data[portrait_name]
		if typeof(portrait) != TYPE_DICTIONARY:
			continue

		var parsed_portrait: Dictionary = portrait.duplicate(true)
		var export_overrides: Dictionary = parsed_portrait.get("export_overrides", {}).duplicate(true)

		for key in export_overrides.keys():
			export_overrides[key] = _parse_variant(export_overrides[key], export_overrides[key])

		parsed_portrait["export_overrides"] = export_overrides
		portraits[str(portrait_name)] = parsed_portrait

	return portraits


func _parse_variant(value, fallback):
	if value is String:
		var stripped: String = value.strip_edges()
		if stripped.begins_with('"') and stripped.ends_with('"'):
			return str_to_var(stripped)
		if stripped.begins_with("Color(") or stripped.begins_with("Vector2("):
			return str_to_var(stripped)
	return value if value != null else fallback


func _to_string_array(value) -> Array:
	var result: Array = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result
