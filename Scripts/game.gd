extends Node2D

@onready var home_base = $HomeBase
@onready var base_life_label = %BaseLifeLabel
@onready var score_label = %ScoreLabel
@onready var wave_label = %WaveLabel
@onready var enemies_left_label = %EnemiesLeftLabel

var points : int
var waves = {1: 10, 2: 20, 3: 30}
var current_wave = 1
var enemies_spawned_for_wave = 0
var enemies_left_for_wave : int

var map_node
var is_valid_position = false
var build_mode= false
var build_valid = false 
var build_location
var tower_to_build 

func _ready():
	score_label.text = "Score: 0"
	wave_label.text = "Wave: " + str(waves.keys()[0])
	enemies_left_label.text = "Enemies Left: " + str(waves.values()[0])
	enemies_left_for_wave = waves[1]
	map_node = get_node("DefenseLevel")
	for i in get_tree().get_nodes_in_group("BuildTowerButtons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))
	#This subscribes to the point_counted signal

func _process(delta):
	base_life_label.text = "Health left: " + str(home_base.health)
	
	if home_base.health == 0:
		print("game over")
		get_tree().reload_current_scene()
		

func initiate_build_mode(tower_type):
	tower_to_build = tower_type
	build_mode = true 
	get_node("BuildTowerButtons").set_tower_preview(tower_to_build, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TileMap").local_to_map(mouse_position)
	var tile_pos = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cell_source_id(0, current_tile):
		get_node("UI").update_tower_preview(tile_pos, "fff")
		build_valid = true 
		build_location = tile_pos
	
	else:
		get_node("UI").update_tower_preview(tile_pos, "000")
		build_valid = false

func on_enemy_died():
	points += 1
	score_label.text = "Score: " + str(points)

#This is to adjust the UI for the enemies left on a wave
func decrement_enemies_left():
	enemies_left_for_wave -= 1
	enemies_left_label.text = "Enemies Left: " + str(enemies_left_for_wave)
	
	if enemies_left_for_wave == 0:
		print("You've killed all of the enemies")
		GlobalSignals.emit_signal("wave_end")
		current_wave += 1
		next_wave_setup()
	
#This listens for the enemy_spawned signal from the paths
#and then adds to the total spawned for that wave. After
#the max for the wave is hit, the paths stop spawning enemies.
func add_to_spawned_wave():
	enemies_spawned_for_wave += 1
	if enemies_spawned_for_wave >= waves[current_wave]:
		print("All enemies for this wave have been spawned")
		GlobalSignals.emit_signal("stop_spawning_enemies")


func next_wave_setup():
	print("Setting wave to " + str(current_wave))
	var next_wave_timer = get_tree().create_timer(5.0)
	next_wave_timer.timeout.connect(start_next_wave)
	
func start_next_wave():
	print("Next wave timer over, starting next wave")
	wave_label.text = "Wave: " + str(current_wave)
	enemies_left_label.text = "Enemies Left: " + str(waves[current_wave])
	enemies_left_for_wave = waves[current_wave]
	enemies_spawned_for_wave = 0
	GlobalSignals.emit_signal("wave_start")


