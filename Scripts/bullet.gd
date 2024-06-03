extends Node2D

@export var speed : float

func _physics_process(delta):
	global_position += Vector2(speed * delta, 0)



func _on_area_2d_body_entered(body):
	print("Hit " + str(body))
