class_name ResourceGenerator
extends Node2D

const GRID_WIDTH = 15
const GRID_HEIGHT = 15
const EMPTY_TYPE = "empty"
const RESOURCE_TYPES = ["stone", "wood", "food", "gold"]
enum RESOURCE_DROP_STATE {
	IDLE,
	DROPPING
}
var resource_spawn_state : int
@export var DroppingResource : Array[PackedScene]
@export var tile_map: TileMap
@export var gatherers_home: Node2D
@export var gatherer_scene: PackedScene
@export var gatherer_icon_texture: Texture2D
@export var gathered_food : PackedScene
var gatherer_icons: Array[Sprite2D] = []
var housed_gatherers: int = 7 
var icon_container: Container
var ground_placed : bool = false
var refresh_button : Button
#var current_highlight: Vector2i = Vector2i(-1, -1)
var resource_totals = {
	"stone": 0,
	"wood": 0,
	"food": 0,
	"gold": 0
}
var ground_tiles = {
	EMPTY_TYPE: [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
}
var resource_tiles = {
	"stone": Vector2i(1, 0),
	"wood": Vector2i(2, 0),
	"food": Vector2i(3, 0),
	"gold": Vector2i(4, 0)
}
var gatherers: Array[Gatherer] = []
var occupied_cells: Dictionary = {}
var resource_save_data = {}
var level_name
var level_state

func _ready():
	resource_spawn_state = RESOURCE_DROP_STATE.IDLE
	level_name = get_tree().get_first_node_in_group("level").name
	level_state = GameManager.get_level_state(level_name) as LevelState
	resource_totals = level_state.gathered_resources
	set_process_input(true)
	spawn_ground()
	setup_gatherer_icons()
	spawn_gatherers(housed_gatherers)
	setup_refresh_button()

func _process(delta):
	if occupied_cells.is_empty() and ground_placed == true and resource_spawn_state == RESOURCE_DROP_STATE.IDLE:
		refresh_button.disabled = false
	else:
		refresh_button.disabled = true
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = get_global_mouse_position()
		var map_pos : Vector2i = tile_map.local_to_map(tile_map.to_local(click_position))
		if tile_map.get_cell_source_id(1, map_pos) != -1:
			send_gatherer_to(map_pos)
				
func spawn_ground():
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			var ground_tile = ground_tiles[EMPTY_TYPE][randi() % ground_tiles[EMPTY_TYPE].size()]
			tile_map.set_cell(0, Vector2i(x, y), 0, ground_tile)
			await get_tree().create_timer(0.0001).timeout 
	ground_placed = true
	if ground_placed:
		load_resources()

func spawn_resources():
	resource_spawn_state = RESOURCE_DROP_STATE.DROPPING
	var animation_promises = []
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			if randf() < 0.2:  # 20% chance to spawn a resource
				var resource = RESOURCE_TYPES[randi() % RESOURCE_TYPES.size()]
				animation_promises.append(await drop_resources(x, y, resource))
				resource_save_data["%d,%d" % [x, y]] = resource
	await Promise.all(animation_promises)
	GameManager.save_resource_data(level_name, resource_save_data)
	await get_tree().create_timer(1).timeout 
	resource_spawn_state = RESOURCE_DROP_STATE.IDLE
	#print("this is what's being saved" + str(resource_save_data))

func drop_resources(x: int, y: int, resource: String):
	var resource_arr_val: int
	match resource:
		"stone": resource_arr_val = 0
		"wood": resource_arr_val = 1
		"food": resource_arr_val = 2
		"gold": resource_arr_val = 3
	var dropping_resource = DroppingResource[resource_arr_val].instantiate()
	dropping_resource.position = tile_map.map_to_local(Vector2i(x, y))
	add_child(dropping_resource)
	
	var animation_player = dropping_resource.get_node("AnimationPlayer")
	animation_player.play("drop")
	
	var promise = Promise.new()
	animation_player.connect("animation_finished", func(_anim_name):
		tile_map.set_cell(1, Vector2i(x, y), 0, resource_tiles[resource])
		resource_save_data["%d,%d" % [x, y]] = resource
		dropping_resource.queue_free()
		promise.resolve()
	)
	
	return promise

func load_resources():
	if level_state.spawned_resource_data.is_empty():
		spawn_resources()
	else:
		resource_spawn_state = RESOURCE_DROP_STATE.DROPPING
		var animation_promises = []
		resource_save_data = level_state.spawned_resource_data
		for pos_str in level_state.spawned_resource_data:
			var pos = pos_str.split(",")
			var x = int(pos[0])
			var y = int(pos[1])
			var resource = level_state.spawned_resource_data[pos_str]
			animation_promises.append(drop_resources(x, y, resource))
		
		await Promise.all(animation_promises)
		await get_tree().create_timer(1).timeout 
		resource_spawn_state = RESOURCE_DROP_STATE.IDLE

class Promise:
	var _resolved = false
	var _callback = null

	func resolve():
		_resolved = true
		if _callback:
			_callback.call()

	func then(callback):
		_callback = callback
		if _resolved:
			_callback.call()

	static func all(promises: Array):
		var remaining = promises.size()
		if remaining == 0:
			return

		var promise = Promise.new()
		
		for p in promises:
			p.then(func():
				remaining -= 1
				if remaining == 0:
					promise.resolve()
			)
		
		return promise

func remove_resources(tilemap: TileMap ,layer: int):
	tilemap.clear_layer(layer)

func refresh_resources():
	remove_resources(tile_map, 1)
	occupied_cells.clear()
	#print(resource_save_data)
	resource_save_data.clear()
	#print(resource_save_data)
	spawn_resources()

func remove_resource_from_save(cell_to_remove: Vector2i):
	#I'm doing this in a really stupid ass way
	#print(resource_save_data)
	var cell_string = "%d,%d" % [cell_to_remove.x, cell_to_remove.y]
	#print("cell_string:" + cell_string)
	resource_save_data.erase(cell_string)
	GameManager.save_resource_data(level_name, resource_save_data)
	#print(resource_save_data)

func setup_gatherer_icons():
	var max_icons_per_row: int = 5
	icon_container = Container.new()
	icon_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	icon_container.position = gatherers_home.position + Vector2(-80, -60)
	icon_container.custom_minimum_size = Vector2(16, 16)

	var grid = GridContainer.new()
	grid.columns = max_icons_per_row
	grid.set_anchors_preset(Control.PRESET_CENTER)
	icon_container.add_child(grid)
	gatherers_home.add_child(icon_container)
	update_gatherer_icons()
	
func update_gatherer_icons():
	var grid = icon_container.get_child(0) as GridContainer
	# Remove excess icons
	while grid.get_child_count() > housed_gatherers:
		var child = grid.get_child(grid.get_child_count() - 1)
		grid.remove_child(child)
		child.queue_free()
	
	# Add missing icons
	while grid.get_child_count() < housed_gatherers:
		var icon = preload("res://Scenes//gatherer_icon.tscn").instantiate()
		#icon.texture = gatherer_icon_texture
		grid.add_child(icon)

func spawn_gatherers(num_gatherers: int):
	for i in range(num_gatherers):
		var gatherer = gatherer_scene.instantiate()
		gatherer.position = gatherers_home.global_position
		gatherer.home_position = gatherers_home.position
		gatherer.connect("remove_saved_resource", remove_resource_from_save)
		gatherers_home.add_child(gatherer)
		gatherers.append(gatherer)
		
func send_gatherer_to(cell_pos):
	if occupied_cells.has(cell_pos):
		flash_red(cell_pos)
		return
		
	for gatherer in gatherers:
		if gatherer.is_available():
			var world_pos = tile_map.to_global(tile_map.map_to_local(cell_pos))
			#print("Sending gatherer to world_pos:", world_pos, "cell_pos:", cell_pos)
			gatherer.move_to(world_pos, cell_pos)
			occupied_cells[cell_pos] = gatherer
			housed_gatherers -= 1
			update_gatherer_icons()
			#print("Occupied cells after sending:", occupied_cells)
			break

func flash_red(cell_pos):
	print(occupied_cells)
	var original_modulate = tile_map.modulate
	tile_map.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	tile_map.modulate = original_modulate

func add_resources(type, amount):
	resource_totals[type] += amount
	print("Total ", type, ": ", resource_totals[type])
	GameManager.save_gathered_resource_data(level_name, resource_totals)


func setup_refresh_button():
	refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.icon = load("res://Assets/refresh.png")
	refresh_button.position = Vector2(375, -50)
	refresh_button.connect("pressed", Callable(self, "refresh_resources"))
	add_child(refresh_button)
