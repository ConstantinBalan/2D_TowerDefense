extends Button

@export var towerType : String
@export var woodCost : int
@export var stoneCost : int
@export var goldCost : int
@export var towerSprite : CompressedTexture2D

var tower_instance : Tower
var tower_data : Dictionary

func _ready():
	tower_data = {
	"type": towerType,
	"level": 1,
	"woodCost": woodCost,
	"stoneCost": stoneCost,
	"goldCost": goldCost,
	"tower_sprite": towerSprite  # Make sure this path is correct
	}
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_button_pressed():
	GlobalSignals.emit_signal("place_tower", tower_data)

func _on_mouse_entered():
	tower_instance = Tower.new(tower_data)
	GlobalSignals.create_tower_ui.emit()
	GlobalSignals.emit_signal("enable_tower_ui", tower_instance.get_info())

func _on_mouse_exited():
	GlobalSignals.delete_tower_ui.emit()
	tower_instance.free()
