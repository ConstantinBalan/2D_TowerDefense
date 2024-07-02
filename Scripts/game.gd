extends Node2D

@onready var home_base = $HomeBase
@onready var base_life_label = %BaseLifeLabel
@onready var wave_label = %WaveLabel
@onready var enemies_left_label = %EnemiesLeftLabel
@onready var coin_amount_label = %CoinAmountLabel
@onready var defense_level = $"."
@onready var tile_map = $TileMap
@onready var towers = $Towers
@export var canvas_layer: CanvasLayer
#-------------------------------------
var TowerScene: PackedScene
var TowerSceneName : String
var TowerUI : PackedScene = preload("res://Scenes/UI/tower_info_popup.tscn")
var tower_ui
var waves : Dictionary = {1: 10, 2: 20, 3: 30, 4: 40, 5: 50}
var current_wave : int = 1
var enemies_spawned_for_wave : int = 0
var enemies_left_for_wave : int
var is_valid_position : bool = false
var build_mode : bool = false
var tower_preview
var towers_overlapping : bool = false
var types_of_towers_placed : Dictionary = {"Regular": 1, "Shotgun": 1, "Machine Gun": 1}
var towers_cur_overlapping : int = 0

#-------------------UI Stuff-------------------
var insufficient_funds_message : PackedScene = load("res://Scenes/UI/insufficient_funds_message_box.tscn")
var move_ui_tween : Tween

var level_name: String
var level_state : LevelState


func _ready():
	_connect_signals()
	_initialize_level()

func _process(delta):
	_update_labels()
	if home_base.health == 0:
		_game_over()
	if build_mode:
		_update_build_mode()

func _connect_signals():
	GlobalSignals.place_tower.connect(initiate_build_mode)
	GlobalSignals.create_tower_ui.connect(spawn_tower_ui)
	GlobalSignals.delete_tower_ui.connect(remove_tower_ui)
	GlobalSignals.towers_are_overlapping.connect(add_tower_overlapping)
	GlobalSignals.towers_not_overlapping.connect(remove_tower_overlapping)

func _initialize_level():
	level_name = name
	level_state = GameManager.get_level_state(level_name)
	_update_labels()
	enemies_left_for_wave = waves[1]

func _update_labels():
	base_life_label.text = "Health left: " + str(home_base.health)
	coin_amount_label.text = "Score: " + str(level_state.coins)
	wave_label.text = "Wave: " + str(level_state.current_wave)
	enemies_left_label.text = "Enemies Left: " + str(enemies_left_for_wave)

func _game_over():
	print("game over")
	get_tree().reload_current_scene()

func initiate_build_mode(tower_data: Dictionary):
	build_mode = true
	TowerScene = load("res://Scenes/tower.tscn")
	set_tower_preview(tower_data)

func _update_build_mode():
	towers_overlapping = towers_cur_overlapping > 0
	update_tower_preview()
	
func spawn_tower_ui():
	tower_ui = TowerUI.instantiate()
	tower_ui.name = "TowerUI"
	$GameUI.add_child(tower_ui)
	tower_ui.show()

func remove_tower_ui():
	if tower_ui:
		tower_ui.queue_free()	

func set_tower_preview(tower_data: Dictionary):
	if tower_preview:
		tower_preview.queue_free()
	var dragable_tower = Tower.new(tower_data)
	dragable_tower.set_name("NewTower")
	var control = Control.new()
	control.add_child(dragable_tower, true)
	control.set_name("TowerPreview")
	#control.get_global_transform()
	towers.add_child(control)
	tower_preview = control

func update_tower_preview():
	if build_mode and tower_preview:
		tower_preview.position = get_global_mouse_position()
		check_valid_spot()
		if is_valid_position and towers_overlapping == false:
			tower_preview.modulate = Color(0, 1, 0, 0.5)  # Green for valid
		else:
			tower_preview.modulate = Color(1, 0, 0, 0.5)  # Red for invalid

func _input(event):
	if build_mode and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_valid_position:
				place_tower()
			else:
				print("Invalid position")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_build_mode()

func check_valid_spot():
	var tile_position = tile_map.local_to_map(get_global_mouse_position())
	var tile_data: TileData = tile_map.get_cell_tile_data(3, tile_position)
	var can_place_tower = tile_data.get_custom_data("can_place_tower") if tile_data else false
	is_valid_position = can_place_tower and not towers_overlapping

func towers_are_overlapping():
	towers_overlapping = true

func towers_not_overlapping():
	towers_overlapping = false

func add_tower_overlapping():
	towers_cur_overlapping += 1
	print("num of towers overlapping: " + str(towers_cur_overlapping))

func remove_tower_overlapping():
	towers_cur_overlapping -= 1
	print("num of towers overlapping: " + str(towers_cur_overlapping))

func _setup_tower(tower_instance):
	towers.add_child(tower_instance)
	tower_instance.position = tower_preview.position
	tower_instance.name = tower_instance.type + str(types_of_towers_placed[tower_instance.type])
	tower_instance.name_label.text = tower_instance.name
	types_of_towers_placed[tower_instance.type] += 1

func place_tower():
	var tower_data = tower_preview.get_child(0).get_info()
	if level_state.coins >= tower_data["cost"]:
		var tower_instance = TowerScene.instantiate() as Tower
		tower_instance._init(tower_data)
		_setup_tower(tower_instance)
		level_state.coins -= tower_data["cost"]
		tower_instance.placed = true
		tower_instance.was_recently_placed = true
		cancel_build_mode()
	else:
		spawn_ui_element()
		print("Not enough coins to build")
		#tower_instance.queue_free()

func cancel_build_mode():
	if tower_preview:
		tower_preview.queue_free()
	build_mode = false
	tower_preview = null

func on_enemy_died():
	level_state.coins += 1
	coin_amount_label.text = "Score: " + str(level_state.coins)

#This is to adjust the UI for the enemies left on a wave
func decrement_enemies_left():
	enemies_left_for_wave -= 1
	enemies_left_label.text = "Enemies Left: " + str(enemies_left_for_wave)
	
	if enemies_left_for_wave == 0:
		print("You've killed all of the enemies")
		GlobalSignals.emit_signal("wave_end")
		level_state.current_wave += 1
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
	wave_label.text = "Wave: " + str(level_state.current_wave)
	enemies_left_label.text = "Enemies Left: " + str(waves[current_wave])
	enemies_left_for_wave = waves[current_wave]
	enemies_spawned_for_wave = 0
	GlobalSignals.emit_signal("wave_start")
	
func spawn_ui_element():
	var insuff_funds_mess_instance = insufficient_funds_message.instantiate()
	$GameUI.add_child(insuff_funds_mess_instance)
	get_tree().create_timer(1).timeout.connect(insuff_funds_mess_instance.queue_free)


