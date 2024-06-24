extends Node2D

@onready var home_base = $HomeBase
@onready var base_life_label = %BaseLifeLabel
@onready var score_label = %ScoreLabel
@onready var wave_label = %WaveLabel
@onready var enemies_left_label = %EnemiesLeftLabel
@onready var defense_level = $"."
@onready var tile_map = $TileMap

@export var canvas_layer: CanvasLayer
var TowerScene: PackedScene
var TowerSceneName : String
var TowerUI : PackedScene = preload("res://Scenes/UI/tower_info_popup.tscn")
var tower_ui
var tower_ui_is_showing = false
var points : int
var waves = {1: 10, 2: 20, 3: 30, 4: 40, 5: 50}
var current_wave = 1
var enemies_spawned_for_wave = 0
var enemies_left_for_wave : int
var mouse_pos
var map_node
var towers
var is_valid_position = false
var build_mode= false
var build_valid = false 
var build_location
var tower_to_build
var tower_preview
var towers_overlapping = false
var types_of_towers_placed : Dictionary = {"Regular Tower": 1, "Shotgun Tower": 1, "MachineGun Tower": 1}
var towers_cur_overlapping : int = 0

#-------------------UI Stuff-------------------
var insufficient_funds_message : PackedScene = load("res://Scenes/UI/insufficient_funds_message_box.tscn")
var move_ui_tween : Tween

func _ready():
	GlobalSignals.place_tower.connect(initiate_build_mode)
	GlobalSignals.create_tower_ui.connect(spawn_tower_ui)
	GlobalSignals.towers_are_overlapping.connect(add_tower_overlapping)
	GlobalSignals.towers_not_overlapping.connect(remove_tower_overlapping)
	score_label.text = "Score: " + str(PlayerStats.coins)
	wave_label.text = "Wave: " + str(waves.keys()[0])
	enemies_left_label.text = "Enemies Left: " + str(waves.values()[0])
	enemies_left_for_wave = waves[1]
	map_node = get_node(".")
	towers = get_node("Towers")


func _process(delta):
	base_life_label.text = "Health left: " + str(home_base.health)
	score_label.text = "Score: " + str(PlayerStats.coins)
	if home_base.health == 0:
		print("game over")
		get_tree().reload_current_scene()
		
	if build_mode:
		if towers_cur_overlapping < 1:
			towers_overlapping = false
		else:
			towers_overlapping = true
		update_tower_preview(get_global_mouse_position())

func initiate_build_mode(tower_type: PackedScene):
	build_mode = true
	TowerScene = tower_type
	set_tower_preview(tower_type, get_global_mouse_position())
	
func spawn_tower_ui():
	if tower_ui:
		tower_ui.queue_free()
	tower_ui = TowerUI.instantiate()
	tower_ui.name = "TowerUI"
	get_node("GameUI").add_child(tower_ui)

	

func set_tower_preview(tower: PackedScene, mouse_pos):
	if tower_preview:
		tower_preview.queue_free()
	var dragable_tower = tower.instantiate()
	dragable_tower.set_name("DragTower")
	var control = Control.new()
	control.add_child(dragable_tower, true)
	control.set_name("TowerPreview")
	control.get_global_transform()
	towers.add_child(control)
	tower_preview = control
	
func update_tower_preview(mouse_pos: Vector2):
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
	var mouse_position = get_global_mouse_position()
	var can_place_tower
	#var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var tile_position = tile_map.local_to_map(mouse_position)
	var tile_data : TileData = tile_map.get_cell_tile_data(3, tile_position)
	if tile_data:
		can_place_tower = tile_data.get_custom_data("can_place_tower")
		
	if can_place_tower and towers_overlapping == false:
		build_valid = true
		is_valid_position = true
		#print("Tower can be placed")
	else:
		build_valid = false
		is_valid_position = false
		#print("NO PLACING")

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


func place_tower():
	if build_valid:
		var tower_instance = TowerScene.instantiate()
		tower_instance.hide()
		if PlayerStats.coins >= tower_instance.tower_cost:
			tower_instance.show()
			tower_instance.position = tower_preview.position
			TowerSceneName = tower_instance.tower_type_name
			tower_instance.name = TowerSceneName + str(types_of_towers_placed[TowerSceneName])
			types_of_towers_placed[TowerSceneName] += 1
			towers.add_child(tower_instance)
			tower_instance.placed = true
			tower_instance.was_recently_placed = true
			PlayerStats.coins -= tower_instance.tower_cost
			cancel_build_mode()
		else:
			spawn_ui_element()
			print("Not enough coins to build")
			tower_instance.queue_free()


func cancel_build_mode():
	if tower_preview:
		tower_preview.queue_free()
	build_mode = false
	tower_to_build = null
	tower_preview = null

func on_enemy_died():
	PlayerStats.coins += 1
	score_label.text = "Score: " + str(PlayerStats.coins)

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
	
# Function to spawn the UI element and start the wiggle effect
func spawn_ui_element():
	
	# Instantiate the UI element if necessary (e.g., if you're creating it dynamically)
	var insuff_funds_mess_instance = insufficient_funds_message.instantiate()
	get_node("GameUI").add_child(insuff_funds_mess_instance)
	#var timer = Timer.new()
	#add_child(timer)
	#timer.wait_time = 1.5 # Time in seconds before hiding the element
	#timer.one_shot = true
	await get_tree().create_timer(1).timeout
	#timer.start()
	insuff_funds_mess_instance.queue_free()

