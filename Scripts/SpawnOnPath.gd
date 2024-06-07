extends Path2D

@export var speed : float
@export var spawn_interval_min : float
@export var spawn_interval_max : float
@export var enemy_paths_to_spawn : Array[PackedScene]
var continue_spawning = true

signal enemy_died()
signal enemy_spawned()

func _ready():
	spawn_enemy()
	

func spawn_enemy():
	var enemy_path = enemy_paths_to_spawn.pick_random()
	var enemy = enemy_path.instantiate()
	
	enemy.get_child(0).died.connect(on_enemy_died)
	enemy.get_child(0).spawned.connect(on_enemy_spawned)
	add_child(enemy)
	
	if continue_spawning == true:
		get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max)).timeout.connect(spawn_enemy)

func on_enemy_died():
	print("Enemy died emitter should run")
	enemy_died.emit()

func on_enemy_spawned():
	print("Enemy spawned emitter should run")
	enemy_spawned.emit()
	
