extends Button

@export var canvas_layer: CanvasLayer

func _process(delta):
	pass
	#global_position = get_global_mouse_position()
	#var current_tile = map_node.get_node("TileMap")
	#if is_valid_position:
	#	modulate = Color(0, 1, 0, 0.5)  # Green with 50% transparency
	#else:
	#	modulate = Color(1, 0, 0, 0.5)  # Red with 50% transparency

func set_tower_preview(tower: PackedScene, mouse_pos):
	var dragable_tower = tower.instantiate()
	dragable_tower.set_name("DragTower")
	#dragable_tower.modulate = Color("ad54ff3c")
	dragable_tower.position = mouse_pos
	dragable_tower.scale.x = 4.0
	dragable_tower.scale.y = 4.0
	canvas_layer.add_child(dragable_tower, true)
	#var control = Control.new()
	#control.add_child(dragable_tower, true)
	#control.position = mouse_pos
	#control.set_name("TowerPreview")
	#add_child(control, true)
	
func update_tower_preview(new_position, color):
	get_node("TowerPreview/DragTower").set_position(new_position)
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
