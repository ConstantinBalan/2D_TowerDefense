extends Control

@export var worlds : Array[Control] = []
@export var playerIcon : Node2D
@export var gemLabel : Label
var current_world : int = 0
var move_tween : Tween

func _ready():
	print(GameManager.game_state.unlocked_worlds)
	update_ui()
	playerIcon.global_position = worlds[current_world].global_position
	print(worlds)

func _input(event):
	if move_tween and move_tween.is_running():
		return
	if event.is_action_pressed("MoveLeft") and current_world > 0:
		current_world -= 1
		print(current_world)
		tween_icon()
	if event.is_action_pressed("MoveRight") and current_world < worlds.size() - 1:
		current_world += 1
		print(current_world)
		tween_icon()
	if event.is_action_pressed("ui_accept"):
		if worlds[current_world].level_select_scene and worlds[current_world].world_name in GameManager.game_state.unlocked_worlds:
			worlds[current_world].level_select_scene.parent_world_select = self
			get_tree().get_root().add_child(worlds[current_world].level_select_scene)
			get_tree().current_scene = worlds[current_world].level_select_scene
			get_tree().get_root().remove_child(self)
		else:
			print("World not unlocked")

func tween_icon():
	move_tween = get_tree().create_tween()
	move_tween.tween_property(playerIcon, "global_position", worlds[current_world].global_position, 0.7).set_trans(Tween.TRANS_SINE)

func update_ui():
	gemLabel.text = "Gems: " + str(GameManager.game_state.gems)
	
	#for level in ["1", "1B", "2", "3"]:
	#	var button = get_node("Level" + level + "Button")
	#	if level in GameManager.game_state.unlocked_levels:
	#		button.disabled = false
	#	else:
	#		button.disabled = true

func _on_level_button_pressed(level: String):
	get_tree().change_scene_to_file("res://levels/level_" + level + ".tscn")

func _on_garden_button_pressed():
	get_tree().change_scene_to_file("res://scenes/garden.tscn")
