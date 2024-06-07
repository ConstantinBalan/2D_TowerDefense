extends CharacterBody2D

@export var speed : float
@export var health : float
@export var impact_damage : float
@onready var health_bar = %ProgressBar

signal died()
signal spawned()

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	spawned.emit()
	
func _physics_process(delta):
	#velocity.x = -speed
	#move_and_slide()
	
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		
		if collider.has_method("take_damage"):
			collider.take_damage(impact_damage)
			died.emit()
			queue_free()
			
func take_damage(damage: float):
	health -= damage
	health_bar.value = health

	if health <= 0:
		print("enemy died")
		died.emit()
		queue_free()
