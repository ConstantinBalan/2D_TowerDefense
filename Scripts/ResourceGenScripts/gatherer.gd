extends CharacterBody2D

var target_position = null
var target_cell = null
var home_position = Vector2.ZERO
var speed = 150
var gathering_progress = 0
var gathering_speed = 50
var carried_resource = null
var carried_amount = 0
var is_gathering : bool = false

@onready var gather_progress = %GatherProgress
@onready var anim = $AnimationPlayer

var resource_generator: Node2D

func _ready():
	gather_progress.visible = false
	visible = false
	resource_generator = get_tree().get_first_node_in_group("resource_generator")
	if not resource_generator:
		push_error("ResourceGenerator not found!")
	home_position = resource_generator.gatherers_home.global_position

func move_to(world_pos, cell):
	if is_gathering:
		return
	is_gathering = true
	target_position = world_pos
	target_cell = cell
	visible = true
	gather_progress.visible = false
	gathering_progress = 0
	print("Gatherer moving to world pos: ", world_pos, " cell: ", cell)

func _physics_process(delta):
	if target_position:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		anim.play("Walk")
		#print("Gatherer position: ", global_position, " target: ", target_position)
		if global_position.distance_to(target_position) < 5:
			if target_cell:
				arrive_at_cell()
			else:
				arrive_at_home()
	elif target_cell:
		anim.play("Gather")
		gather(delta)

func is_available():
	return not is_gathering and carried_resource == null

func arrive_at_cell():
	position = target_position
	target_position = null
	gather_progress.visible = true
	gather_progress.max_value = 100

func arrive_at_home():
	position = resource_generator.gatherers_home.global_position
	if carried_resource:
		resource_generator.add_resources(carried_resource, carried_amount)
		carried_resource = null
		carried_amount = 0
	target_position = null
	target_cell = null
	is_gathering = false
	visible = false
	resource_generator.housed_gatherers += 1
	resource_generator.update_gatherer_icons()
	resource_generator.occupied_cells.erase(target_cell)


func gather(delta):
	gathering_progress += gathering_speed * delta
	gather_progress.value = gathering_progress
	if gathering_progress >= 100:
		collect_resource()

func collect_resource():
	var current_coords = resource_generator.tile_map.get_cell_atlas_coords(1, target_cell)
	var resource_type = "empty"
	for type in resource_generator.RESOURCE_TYPES:
		if current_coords == resource_generator.resource_tiles[type]:
			resource_type = type
			break
	if resource_type != "empty":
		print("Collected ", resource_type)
		carried_resource = resource_type
		carried_amount = 10  # You can adjust this or make it random
		resource_generator.tile_map.erase_cell(1, target_cell)
	gather_progress.visible = false
	gathering_progress = 0
	target_cell = null
	is_gathering = false
	anim.stop()
	return_to_home()
	
func return_to_home():
	move_to(home_position, null)

