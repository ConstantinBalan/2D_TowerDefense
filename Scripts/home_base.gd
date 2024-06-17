extends Area2D


@export var health : float
@onready var health_bar = %HealthBar

signal died_to_base

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func take_damage(damage: float):
	health -= damage
	health_bar.value = health

	#maybe having a signal emit to the game when the health
	#hits 0 would be. Nevermind I already do this in game.gd
	#This functionally doesn't do shit
	if health <= 0:
		print("you died")

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage(5.0)
		died_to_base.emit()
		body.queue_free()


func _on_body_exited(body):
	pass # Replace with function body.
