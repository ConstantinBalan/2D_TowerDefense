extends Node

var game_state: GameState
const SAVE_PATH = "user://game_state.tres"
var level_difficulty: String

func _ready() -> void:
	load_game()

func save_game() -> void:
	game_state.save(SAVE_PATH)

func load_game() -> void:
	game_state = GameState.load(SAVE_PATH)

func update_gems(amount: int) -> void:
	game_state.gems += amount
	save_game()

func unlock_level(level_name: String) -> void:
	if level_name not in game_state.unlocked_levels:
		game_state.unlocked_levels.append(level_name)
		game_state.get_or_create_level_state(level_name)
		save_game()
		
func unlock_world(world_name: String) -> void:
	if world_name not in game_state.unlocked_worlds:
		game_state.unlocked_worlds.append(world_name)
		print("Saving " + str(world_name))
		save_game()

func upgrade_tower(tower_type: String, level: int) -> void:
	game_state.tower_levels[tower_type] = level
	save_game()

func add_garden_decoration(decoration: Dictionary) -> void:
	game_state.garden_decorations.append(decoration)
	save_game()

func save_level_state(level_name: String, coins: int, wave: int, towers: Array[Dictionary]) -> void:
	var level_state = game_state.get_or_create_level_state(level_name)
	level_state.coins = coins
	level_state.current_wave = wave
	level_state.towers = towers
	save_game()

func save_resource_data(level_name: String, resource_data: Dictionary) -> void:
	var level_state = game_state.get_or_create_level_state(level_name)
	level_state.spawned_resource_data = resource_data
	save_game()
	
func save_gathered_resource_data(level_name: String, resource_totals: Dictionary):
	var level_state = game_state.get_or_create_level_state(level_name)
	level_state.gathered_resources = resource_totals
	save_game()

func get_level_state(level_name: String) -> LevelState:
	return game_state.get_or_create_level_state(level_name)
