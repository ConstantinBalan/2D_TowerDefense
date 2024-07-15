extends Node2D

const GRID_WIDTH = 15
const GRID_HEIGHT = 15
const EMPTY_TYPE = "empty"
const RESOURCE_TYPES = ["stone", "wood", "food", "gold"]

@export var tile_map: TileMap
@export var gatherers_home: Node2D
#@export var highlight_tile: Vector2i
@export var gatherer_icon_texture: Texture2D
var gatherer_icons: Array[Sprite2D] = []
var housed_gatherers: int = 7 
var max_icons_per_row: int = 5
var icon_container: Container
var ground_placed : bool = false
#var current_highlight: Vector2i = Vector2i(-1, -1)
var ground_tiles = {
	EMPTY_TYPE: [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
}
var resource_totals = {
	"stone": 0,
	"wood": 0,
	"food": 0,
	"gold": 0
}
var resource_tiles = {
	"stone": Vector2i(1, 0),
	"wood": Vector2i(2, 0),
	"food": Vector2i(3, 0),
	"gold": Vector2i(4, 0)
}
var gatherers = []
var occupied_cells: Dictionary = {}

func _ready():
	set_process_input(true)
	spawn_ground()
	setup_gatherer_icons()
	spawn_gatherers(housed_gatherers)
	setup_refresh_button()
	
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = get_global_mouse_position()
		var map_pos = tile_map.local_to_map(tile_map.to_local(click_position))
		print("Clicked at global position: ", click_position)
		print("Converted to map position: ", map_pos)
		if tile_map.get_cell_source_id(1, map_pos) != -1:
			print("Valid cell clicked")  # Debug print
			send_gatherer_to(map_pos)
				
func spawn_ground():
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			var ground_tile = ground_tiles[EMPTY_TYPE][randi() % ground_tiles[EMPTY_TYPE].size()]
			tile_map.set_cell(0, Vector2i(x, y), 0, ground_tile)
			await get_tree().create_timer(0.001).timeout 
	ground_placed = true
	if ground_placed:
		spawn_resources()

func spawn_resources():
	for y in range(GRID_WIDTH):
		for x in range(GRID_HEIGHT):
			if randf() < 0.2:  # 20% chance to spawn a resource
				var resource = RESOURCE_TYPES[randi() % RESOURCE_TYPES.size()]
				tile_map.set_cell(1, Vector2i(x, y), 0, resource_tiles[resource])

func refresh_resources():
	#spawn_ground()
	spawn_resources()
	#for x in range(GRID_WIDTH):
	#	for y in range(GRID_HEIGHT):
	#		var cell_pos = Vector2i(x, y)
	#		if tile_map.get_cell_source_id(1, cell_pos) == -1:# If no resource here
	#			if randf() < 0.3:  # 30% chance to spawn a resource
	#				var resource = RESOURCE_TYPES[randi() % RESOURCE_TYPES.size()]
	#				tile_map.set_cell(1, cell_pos, 0, resource_tiles[resource])

func setup_gatherer_icons():
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
		var gatherer = preload("res://Scenes//gatherer.tscn").instantiate()
		gatherer.position = gatherers_home.global_position
		gatherer.home_position = gatherers_home.position
		gatherers_home.add_child(gatherer)
		gatherers.append(gatherer)
		
func send_gatherer_to(cell_pos):
	if occupied_cells.has(cell_pos):
		flash_red(cell_pos)
		return
		
	for gatherer in gatherers:
		if gatherer.is_available():
			var world_pos = tile_map.map_to_local(cell_pos)
			gatherer.move_to(tile_map.to_global(world_pos), cell_pos)
			occupied_cells[cell_pos] = gatherer
			housed_gatherers -= 1
			update_gatherer_icons()
			break

func flash_red(cell_pos):
	var original_modulate = tile_map.modulate
	tile_map.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	tile_map.modulate = original_modulate

func add_resources(type, amount):
	resource_totals[type] += amount
	print("Total ", type, ": ", resource_totals[type])


func setup_refresh_button():
	var refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.icon = load("res://Assets/refresh.png")
	refresh_button.position = Vector2(375, -50)
	refresh_button.connect("pressed", Callable(self, "refresh_resources"))
	add_child(refresh_button)
