extends Node2D

@onready var home_base = $HomeBase
@onready var base_life_label = $CanvasLayer/BaseLifeLabel
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var enemies_left_label = $CanvasLayer/EnemiesLeftLabel

signal wave_over()
signal stop_spawning_enemies()

var points : int
var waves = {1: 20, 2: 30, 3: 40}
var current_wave = 1
var enemies_spawned_for_wave = 0

func _ready():
	score_label.text = "Score: 0"
	wave_label.text = "Wave: " + str(waves.keys()[0])
	enemies_left_label.text = "Enemies Left: " + str(waves.values()[0])
	
	#This subscribes to the point_counted signal


func _process(delta):
	base_life_label.text = str(home_base.health)
	
	if home_base.health == 0:
		print("game over")
		get_tree().reload_current_scene()
		
func on_enemy_died():
	points += 1
	score_label.text = "Score: " + str(points)

func decrement_enemies_left():
	pass
	
func add_to_spawned_wave():
	enemies_spawned_for_wave += 1
	
	if enemies_spawned_for_wave >= waves[current_wave]:
		print("All enemies for this wave have been spawned")
		stop_spawning_enemies.emit()
		pass
	
func next_wave():
	pass

