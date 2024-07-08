class_name PlayerCharacter
extends CharacterBody2D

@export var Health : int



@export var speed = 150.0
@export var accel = 1.0


func _ready():
	pass

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal_direction = Input.get_axis("MoveLeft", "MoveRight")
	var vertical_direction = Input.get_axis("MoveUp", "MoveDown")
	if horizontal_direction:
		velocity.x = horizontal_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if vertical_direction:
		velocity.y = vertical_direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()
