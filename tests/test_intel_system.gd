extends RefCounted

const IntelSystemScript = preload("res://autoload/intel_system.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var save_path := "user://test_intel_system_save.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	var intel_system = IntelSystemScript.new()
	intel_system.save_path = save_path
	intel_system._load_intel_database()

	if intel_system.has_intel("intel_city_fall"):
		failures.append("fresh intel system should start without intel")

	if not intel_system.acquire_intel("intel_city_fall"):
		failures.append("acquire_intel should succeed for valid intel")

	if not intel_system.has_intel("intel_city_fall"):
		failures.append("acquired intel should be stored")

	intel_system.trigger_loop_reset()
	if intel_system.current_loop != 1:
		failures.append("trigger_loop_reset should increment current_loop")

	var reloaded = IntelSystemScript.new()
	reloaded.save_path = save_path
	reloaded._load_intel_database()
	reloaded._load_persistent_data()

	if reloaded.current_loop != 1:
		failures.append("persistent load should restore loop count")

	if not reloaded.has_intel("intel_city_fall"):
		failures.append("persistent load should restore acquired intel")

	reloaded.mark_tutorial_seen()
	var tutorial_reload = IntelSystemScript.new()
	tutorial_reload.save_path = save_path
	tutorial_reload._load_intel_database()
	tutorial_reload._load_persistent_data()
	if not tutorial_reload.tutorial_seen:
		failures.append("tutorial_seen should persist across reloads")

	tutorial_reload.reset_all()
	if tutorial_reload.current_loop != 0 or not tutorial_reload.acquired_intels.is_empty():
		failures.append("reset_all should clear loop and intel state")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	return failures
