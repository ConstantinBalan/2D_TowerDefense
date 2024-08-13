extends Camera2D

enum CAMERA_POSITION_STATE {
	GRID,
	VILLAGE,
	MAP
}
var curr_camera_pos : CAMERA_POSITION_STATE
var positions = {
	CAMERA_POSITION_STATE.GRID: Vector2(-688, -64),
	CAMERA_POSITION_STATE.VILLAGE: Vector2(-216, -632),
	CAMERA_POSITION_STATE.MAP: Vector2(0, 0)
}

func _ready():
	curr_camera_pos = CAMERA_POSITION_STATE.MAP
	
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("MoveCameraToGrid") and curr_camera_pos != CAMERA_POSITION_STATE.GRID:
		move_to_pressed_location(CAMERA_POSITION_STATE.GRID)
	if event.is_action_pressed("MoveCameraToVillage") and curr_camera_pos != CAMERA_POSITION_STATE.VILLAGE:
		move_to_pressed_location(CAMERA_POSITION_STATE.VILLAGE)
	if event.is_action_pressed("MoveCameraToMap") and curr_camera_pos != CAMERA_POSITION_STATE.MAP:
		move_to_pressed_location(CAMERA_POSITION_STATE.MAP)

func move_to_pressed_location(new_pos_state: CAMERA_POSITION_STATE):
	if new_pos_state != curr_camera_pos:
		var tween = create_tween()
		tween.tween_property(self, "global_position", positions[new_pos_state], 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		curr_camera_pos = new_pos_state
