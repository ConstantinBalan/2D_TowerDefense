extends Marker2D

@export var spawn_interval_min : float
@export var spawn_interval_max : float
@export var enemies_to_spawn : Array[PackedScene]

signal enemy_died

func _ready():
	spawn_enemy()

func spawn_enemy():
	var spawnable_enemy = enemies_to_spawn.pick_random()
	var enemy = spawnable_enemy.instantiate()
	
	enemy.died.connect(on_enemy_died)
	add_child(enemy)
	
	get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max)).timeout.connect(spawn_enemy)

func on_enemy_died():
	enemy_died.emit()
