extends Path2D

@export var speed : float
@export var spawn_interval_min : float
@export var spawn_interval_max : float
@export var enemy_paths_to_spawn : Array[PackedScene]
var continue_spawning = true
var active_timers = []

signal enemy_died
signal enemy_spawned

func _ready():
	GlobalSignals.stop_spawning_enemies.connect(spawner_stop)
	GlobalSignals.wave_start.connect(spawner_start)
	spawn_enemy()
	

func spawn_enemy():
	if continue_spawning:
		var enemy_path = enemy_paths_to_spawn.pick_random()
		var enemy = enemy_path.instantiate()
	
		enemy.get_child(0).died.connect(on_enemy_died)
		enemy.get_child(0).spawned.connect(on_enemy_spawned)
		add_child(enemy)
	
		var timer = get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max), false)
		timer.timeout.connect(spawn_enemy)
		#active_timers.append(timer)

func on_enemy_died():
	#print("Enemy died emitter should run")
	enemy_died.emit()

func on_enemy_spawned():
	#print("Enemy spawned emitter should run")
	enemy_spawned.emit()
	
func spawner_stop():
	#print("End of wave triggered, stop spawning enemies.")
	continue_spawning = false
	
func spawner_start():
	#print("Start of wave triggered, start spawning enemies.")
	continue_spawning = true
	spawn_enemy()
