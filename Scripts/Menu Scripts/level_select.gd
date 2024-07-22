extends Control
class_name LevelSelect

@onready var level_select_ui = %LevelSelectUI
@onready var current_level : LevelIcon = $"1"
@onready var curr_world : String
var parent_world_select : Node
var move_tween : Tween
var diff_select_ui = null
@export var level_select_difficulty_ui : PackedScene

func _ready():
	$PlayerIcon.global_position = current_level.global_position

func _input(event):
	if move_tween and move_tween.is_running():
		return
		
	if diff_select_ui == null:
		if event.is_action_pressed("MoveLeft") and  current_level.next_level_left:
			current_level = current_level.next_level_left
			tween_icon()
		if event.is_action_pressed("MoveRight") and  current_level.next_level_right:
			current_level = current_level.next_level_right
			tween_icon()
		if event.is_action_pressed("MoveUp") and  current_level.next_level_up:
			current_level = current_level.next_level_up
			tween_icon()
		if event.is_action_pressed("MoveDown") and  current_level.next_level_down:
			current_level = current_level.next_level_down
			tween_icon()
		
		if event.is_action_pressed("ui_cancel"):
			get_tree().get_root().add_child(parent_world_select)
			get_tree().current_scene = parent_world_select
			get_tree().get_root().remove_child(self)
	
		if event.is_action_pressed("ui_accept"):
			select_new_level_difficulty()
		#Eventually another UI element i'll add will be check if
		#There is a level_state for the level you select.
		#Then an alt "continue save or start new" UI will come up
		#if current_level.next_scene_path:
			#get_tree().change_scene_to_file(current_level.next_scene_path)

func select_new_level_difficulty():
	if diff_select_ui == null:
		diff_select_ui = level_select_difficulty_ui.instantiate()
		var ui_level_name: String = curr_world + " " + current_level.name
		level_select_ui.add_child(diff_select_ui)
		diff_select_ui.setup_ui_info(ui_level_name, current_level.level_image_preview)
		diff_select_ui.setup_level_scene(current_level.next_scene_path)
	
func tween_icon():
	move_tween = get_tree().create_tween()
	move_tween.tween_property($PlayerIcon, "global_position", current_level.global_position, 0.5).set_trans(Tween.TRANS_SINE)
