extends Resource
class_name LevelState

@export var coins: int = 10
@export var current_wave: int = 1
@export var towers: Array[Dictionary] = []

func save(path: String) -> void:
	ResourceSaver.save(self, path)

static func load(path: String) -> LevelState:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as LevelState
	return LevelState.new()
