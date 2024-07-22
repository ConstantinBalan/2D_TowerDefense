extends Node2D

@export var speed : float
@export var damage : float
var target = null
var target_position_on_bullet_spawn : Vector2

func _ready():
	pass
	#if is_instance_valid(target):
	#	target_position_on_bullet_spawn = target.global_position


func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
	else:
		#print("bullet was still in air when enemy died")
		queue_free()
	


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
