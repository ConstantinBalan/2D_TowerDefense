extends Control

signal resume_game
signal toggle_pause


@onready var pause_menu = $"."

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		emit_signal("toggle_pause")


func _on_resume_button_pressed():
	emit_signal("resume_game")


func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Levels/Menus/main_menu.tscn")
