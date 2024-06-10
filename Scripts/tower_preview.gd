extends Node2D

@export var TowerScene: PackedScene
var is_valid_position = false

func _ready():
	set_process(true)

func _process(delta):
	global_position = get_global_mouse_position()
	if is_valid_position:
		modulate = Color(0, 1, 0, 0.5)  # Green with 50% transparency
	else:
		modulate = Color(1, 0, 0, 0.5)  # Red with 50% transparency

func set_valid_position(valid):
	is_valid_position = valid
