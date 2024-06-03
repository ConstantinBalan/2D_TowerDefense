extends StaticBody2D


@export var health : float
@onready var health_bar = %HealthBar


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

