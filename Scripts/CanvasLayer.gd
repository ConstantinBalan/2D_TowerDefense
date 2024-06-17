extends CanvasLayer

@export var canvas_layer: CanvasLayer
var local_pos = Vector2(10, 20)
func set_tower_preview(tower: PackedScene, mouse_pos):
	var dragable_tower = tower.instantiate()
	dragable_tower.set_name("DragTower")
	#dragable_tower.modulate = Color("ad54ff3c")
	dragable_tower.scale = Vector2(4.0, 4.0)
	var control = Control.new()
	control.add_child(dragable_tower, true)
	#control.position = get_viewport_transform() * (get_global_transform() * local_pos)
	control.set_name("TowerPreview")
	add_child(control, true)
	return dragable_tower
	
func update_tower_preview(new_position, color):
	var preview = get_node("DragTower")
	if preview:
		preview.position = new_position
		if preview.modulate != Color(color):
			preview.modulate = Color(color)
