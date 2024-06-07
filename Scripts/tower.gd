extends Node2D
@onready var shoot_cooldown_timer = $ShootCooldownTimer
@export var projectile : PackedScene
@export var attack_rate = 0.5
var targets : Array
var cur_target = null
var can_attack = true

func _ready():
	shoot_cooldown_timer.start()

func _process(delta):
	if cur_target and cur_target.is_inside_tree() and can_attack:
		shoot_bullet()
		can_attack = false
		await get_tree().create_timer(attack_rate).timeout
		can_attack = true
	#if cur_target:
	#	_on_timer_timeout(cur_target)



func shoot_bullet():
	var projectile = projectile
	var bullet = projectile.instantiate()
	bullet.speed = 35.0
	bullet.damage = 5.0
	bullet.target = cur_target
	
	bullet.global_position = global_position
	
	get_parent().add_child(bullet)
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		if body not in targets:
			targets.append(body)
			if not cur_target:
				cur_target = body
				

func _on_area_2d_body_exited(body):
	if body.is_in_group("enemy"):
		if body in targets:
			targets.erase(body)
			if body == cur_target:
				cur_target = null
				if targets.size() > 0:
					cur_target = targets[0]
