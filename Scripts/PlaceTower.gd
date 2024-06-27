extends Button

@export var towerType : PackedScene

func _ready():
	self.connect("pressed", _on_button_pressed)
	self.connect("mouse_entered", _on_mouse_entered)
	self.connect("mouse_exited", _on_mouse_exited)
	

func _on_button_pressed():
	print("Button pressed")
	GlobalSignals.emit_signal("place_tower", towerType)

func _on_mouse_entered():
	var tower_instance = towerType.instantiate()
	GlobalSignals.create_tower_ui.emit()
	GlobalSignals.emit_signal("enable_tower_ui", tower_instance.tower_type_name, tower_instance.tower_cost, tower_instance.tower_level, tower_instance.tower_damage, tower_instance.attack_rate)
	print("hello")

func _on_mouse_exited():
	GlobalSignals.delete_tower_ui.emit()
	print("goodbye")

func _process(delta):
	pass
	#if is_hovered():
		#print("hovering")
		#GlobalSignals.create_tower_ui.emit()
		#var tower_instance = towerType.instantiate()
		#GlobalSignals.emit_signal("enable_tower_ui", tower_instance.tower_type_name, tower_instance.tower_cost, tower_instance.tower_level, tower_instance.tower_damage, tower_instance.attack_rate)

	#else:
	#	GlobalSignals.delete_tower_ui.emit()
