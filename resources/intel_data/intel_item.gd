extends Resource
class_name IntelItem

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var category: StringName = &"general"  # general / character / conspiracy / truth
@export var source_loop: int = -1
@export var icon: Texture2D = null
@export var unlocks_branches: Array[String] = []
