extends CharacterBody2D

@export var speed : float
@export var health : float
@export var impact_damage : float
@onready var health_bar = $HealthBar

signal died
signal spawned

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	spawned.emit()

func take_damage(damage: float):
	health -= damage
	health_bar.value = health

	if health <= 0:
		die()
		
func die():
	print("enemy died")
	died.emit()
	queue_free()
