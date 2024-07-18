extends Resource
class_name LevelState

@export var coins: int = 10
@export var gathered_resources : Dictionary = {
	"stone": 0,
	"wood": 0,
	"food": 0,
	"gold": 0
}
@export var current_wave: int = 1
@export var towers: Array[Dictionary] = []
@export var spawned_resource_data : Dictionary = {}

func save(path: String) -> void:
	ResourceSaver.save(self, path)

static func load(path: String) -> LevelState:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as LevelState
	return LevelState.new()
