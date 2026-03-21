@tool
extends SceneTree

const TEST_SCRIPTS := [
	"res://tests/test_intel_system.gd",
	"res://tests/test_branch_unlocks.gd",
]


func _initialize() -> void:
	var failures: Array[String] = []

	for script_path in TEST_SCRIPTS:
		var test_script = load(script_path)
		var test = test_script.new()
		var result: Array[String] = test.run()
		if result.is_empty():
			print("PASS %s" % script_path)
		else:
			for failure in result:
				failures.append("%s: %s" % [script_path, failure])
				push_error("%s: %s" % [script_path, failure])

	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("TEST FAILURES: %d" % failures.size())
		quit(1)
