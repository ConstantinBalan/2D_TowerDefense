extends Resource
class_name GameState

@export var gems: int = 0
@export var unlocked_levels: Array[String] = []
@export var tower_levels: Dictionary = {}
@export var garden_decorations: Array[Dictionary] = []
@export var level_states: Dictionary = {}
var save_path = "user://playersave.save"

func save(path: String) -> void:
	ResourceSaver.save(self, path)

static func load(path: String) -> GameState:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as GameState
	return GameState.new()

func get_or_create_level_state(level_name: String) -> LevelState:
	if not level_states.has(level_name):
		level_states[level_name] = LevelState.new()
	return level_states[level_name]

