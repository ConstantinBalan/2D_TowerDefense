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

@onready var carried_resource_icon = %CarriedResourceIcon
@onready var gather_progress = %GatherProgress
@onready var anim = $AnimationPlayer

@onready var resource_sprite_map = preload("res://Assets/Resourcetilemap.png")
var resource_generator: Node2D
@onready var gold_particles = %GoldParticles

func _ready():
	carried_resource_icon.visible = false
	gather_progress.visible = false
	visible = false
	gold_particles.visible = false
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
	carried_resource_icon.visible = false
	visible = false
	resource_generator.housed_gatherers += 1
	resource_generator.update_gatherer_icons()
	resource_generator.occupied_cells.erase(target_cell)


func gather(delta):
	gathering_progress += gathering_speed * delta
	gather_progress.value = gathering_progress
	gold_particles.visible = true
	if gathering_progress >= 100:
		gold_particles.visible = false
		collect_resource()


func collect_resource():
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
		resource_generator.tile_map.erase_cell(1, target_cell)
		
	gather_progress.visible = false
	gathering_progress = 0
	target_cell = null
	is_gathering = false
	anim.stop()
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

