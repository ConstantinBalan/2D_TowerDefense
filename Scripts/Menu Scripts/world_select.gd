extends Control

@export var worlds : Array[Control] = []
var current_world : int = 0
var move_tween : Tween

func _ready():
	$PlayerIcon.global_position = worlds[current_world].global_position

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
		if worlds[current_world].level_select_scene:
			worlds[current_world].level_select_scene.parent_world_select = self
			get_tree().get_root().add_child(worlds[current_world].level_select_scene)
			get_tree().current_scene = worlds[current_world].level_select_scene
			get_tree().get_root().remove_child(self)

func tween_icon():
	move_tween = get_tree().create_tween()
	move_tween.tween_property($PlayerIcon, "global_position", worlds[current_world].global_position, 0.7).set_trans(Tween.TRANS_SINE)
