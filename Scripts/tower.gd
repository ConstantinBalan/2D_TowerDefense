extends Node2D
@onready var shoot_cooldown_timer = $ShootCooldownTimer
@export var projectile : PackedScene
var targets = []

func _ready():
	shoot_cooldown_timer.start()


func _on_timer_timeout():
	var projectile = projectile
	var bullet = projectile.instantiate()
	bullet.speed = 25.0
	bullet.damage = 5.0
	
	bullet.global_position = global_position
	
	get_parent().add_child(bullet)
	
	
