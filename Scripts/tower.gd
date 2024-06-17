extends Node2D
@export var projectile : PackedScene
@export var attack_rate : float
@export var placed = false
var targets : Array
var cur_target = null
var can_attack = true


func _ready():
	pass
	
func _process(delta):
	if cur_target and cur_target.is_inside_tree() and can_attack:
		shoot_bullet(38.0,5.0)
		can_attack = false
		await get_tree().create_timer(attack_rate).timeout
		can_attack = true
	#if cur_target:
	#	_on_timer_timeout(cur_target)



func shoot_bullet(speed: float, damage: float):
	if placed:
		var projectile = projectile
		var bullet = projectile.instantiate()
		bullet.speed = speed
		bullet.damage = damage
		bullet.target = cur_target
		bullet.global_position = get_parent().position
		self.add_child(bullet)
	

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
