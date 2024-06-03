extends Node2D
@onready var timer = $Timer

func _ready():
	timer.start()


func _on_timer_timeout():
	const BULLET = preload("res://Scenes/bullet.tscn")
	var bullet = BULLET.instantiate()
	bullet.speed = 25.0
	add_child(bullet)
