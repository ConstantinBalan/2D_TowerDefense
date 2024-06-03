extends Node2D

@onready var home_base = $HomeBase
@onready var base_life_label = $CanvasLayer/BaseLifeLabel
@onready var score_label = $CanvasLayer/ScoreLabel

var points : int

func _ready():
	score_label.text = "Score: 0"
	#This subscribes to the point_counted signal


func _process(delta):
	base_life_label.text = str(home_base.health)
	
	if home_base.health == 0:
		print("game over")
		get_tree().reload_current_scene()
		
func on_fish_died():
	points += 1
	score_label.text = "Score: " + str(points)

