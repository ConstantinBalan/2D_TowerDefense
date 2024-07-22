class_name Gatherer
extends CharacterBody2D

var target_position = null
var target_cell = null
var cell_to_remove = null
var home_position = Vector2.ZERO
var speed = 150
var gathering_progress = 0
var gathering_speed = 50
var carried_resource = null
var carried_amount: int = 0
var is_gathering: bool = false
enum STATE {
	IDLE,
	MOVING_TO_RESOURCE,
	GATHERING,
	RETURNING_HOME
}
var state : int = STATE.IDLE

@export var carried_resource_icon: Sprite2D
@export var gather_progress: ProgressBar
@export var anim: AnimationPlayer
@export var resource_sprite_map: CompressedTexture2D
var resource_generator: ResourceGenerator
var level_name : String

signal remove_saved_resource(resource_pos: Vector2i)

func _ready():
	carried_resource_icon.visible = false
	gather_progress.visible = false
	visible = false
	resource_generator = get_tree().get_first_node_in_group("resource_generator")
	if not resource_generator:
		push_error("ResourceGenerator not found!")
	level_name = get_tree().get_first_node_in_group("level").name
	if level_name == null:
		push_error("Could not get level name for gatherer")
	home_position = resource_generator.gatherers_home.global_position
	
func _physics_process(delta):
	if target_position != null:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		anim.play("Walk")
		#print("Gatherer position: ", global_position, " target: ", target_position)
		if global_position.distance_to(target_position) < 5:
			if state == STATE.MOVING_TO_RESOURCE:
				arrive_at_cell()
			elif  STATE.RETURNING_HOME:
				arrive_at_home()
			else:
				print("Unexpected state:", state)
	elif state == STATE.GATHERING:
		anim.play("Gather")
		gather(delta)

func move_to(world_pos, cell):
	if is_gathering: #Won't go to another cell if the gatherer is already out
		return
	is_gathering = true
	target_position = world_pos
	target_cell = cell
	visible = true
	gathering_progress = 0
	
	if cell == null:
		state = STATE.RETURNING_HOME
		#print("Moving home. world_pos: " + str(world_pos) + "cell: null")
	else:
		state = STATE.MOVING_TO_RESOURCE
		#print("Moving to resource. world_pos:", world_pos, "cell:", cell)


func is_available():
	return state == STATE.IDLE

func arrive_at_cell():
	#global_position = target_position
	target_position = null
	gather_progress.visible = true
	gather_progress.max_value = 100
	state = STATE.GATHERING
	#print("Gatherer arrived at cell:", target_cell)


func arrive_at_home():
	#print("Were back home")
	#position = resource_generator.gatherers_home.global_position
	if cell_to_remove != null:
		resource_generator.occupied_cells.erase(cell_to_remove)
		emit_signal("remove_saved_resource", cell_to_remove)
		cell_to_remove = null
	if carried_resource:
		resource_generator.add_resources(carried_resource, carried_amount)
		carried_resource = null
		carried_amount = 0
	target_position = null
	target_cell = null
	is_gathering = false
	carried_resource_icon.visible = false
	visible = false
	resource_generator.housed_gatherers += 1
	resource_generator.update_gatherer_icons()
	state = STATE.IDLE


func gather(delta):
	print("Were now gathering")
	gathering_progress += gathering_speed * delta
	gather_progress.value = gathering_progress
	if gathering_progress >= 100:
		collect_resource()

func collect_resource():
	print("Finished resource collection at cell:", target_cell)
	var current_coords = resource_generator.tile_map.get_cell_atlas_coords(1, target_cell)
	var resource_type = "empty"
	for type in resource_generator.RESOURCE_TYPES:
		if current_coords == resource_generator.resource_tiles[type]:
			resource_type = type
			break
	match resource_type:
		"food":
			play_food_gathered_animation(resource_generator.tile_map.map_to_local(target_cell))
			set_carried_resource_icon("food", 3, 0)
		"wood":
			set_carried_resource_icon("wood", 2, 0)
		"stone":
			set_carried_resource_icon("stone",1, 0)
		"gold":
			set_carried_resource_icon("gold",4, 0)
	if resource_type != "empty":
		print("Collected ", resource_type)
		carried_resource = resource_type
		carried_amount = 10  # You can adjust this or make it random
		cell_to_remove = target_cell
		print(cell_to_remove)
		resource_generator.tile_map.erase_cell(1, target_cell)
	target_cell = null
	gather_progress.visible = false
	gathering_progress = 0
	is_gathering = false
	anim.stop()
	state = STATE.RETURNING_HOME
	return_to_home()
	
func play_food_gathered_animation(position):
	var food_gathered = resource_generator.gathered_food.instantiate()
	resource_generator.add_child(food_gathered)
	food_gathered.position = position
	food_gathered.get_node("AnimationPlayer").play("Food_Collected")
	
	# Optional: Remove the node after the animation finishes
	await food_gathered.get_node("AnimationPlayer").animation_finished
	food_gathered.queue_free()
	
func set_carried_resource_icon(resourceType: String, x: int , y: int):
	match resourceType:
		"food":
			carried_resource_icon.texture = resource_sprite_map
			carried_resource_icon.region_enabled = true
			var rect = Rect2(x * 32, y * 32, 32, 32)
			carried_resource_icon.region_rect = rect
		"wood":
			carried_resource_icon.texture = resource_sprite_map
			carried_resource_icon.region_enabled = true
			var rect = Rect2(x * 32, y * 32, 32, 32)
			carried_resource_icon.region_rect = rect
		"stone":
			carried_resource_icon.texture = resource_sprite_map
			carried_resource_icon.region_enabled = true
			var rect = Rect2(x * 32, y * 32, 32, 32)
			carried_resource_icon.region_rect = rect
		"gold":
			carried_resource_icon.texture = resource_sprite_map
			carried_resource_icon.region_enabled = true
			var rect = Rect2(x * 32, y * 32, 32, 32)
			carried_resource_icon.region_rect = rect
	carried_resource_icon.visible = true
	
func return_to_home():
	move_to(home_position, null)

