extends Button

@export var towerType : PackedScene

func _ready():
	self.connect("pressed", _on_button_pressed)

func _on_button_pressed():
	print("Button pressed")
	GlobalSignals.emit_signal("place_tower", towerType)
