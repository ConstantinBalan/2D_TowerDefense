extends Node

@onready var info_window = $".."
@onready var ui_tower_name = %TowerName
@onready var tower_photo = %TowerPhoto
@onready var ui_tower_cost = %TowerCost
@onready var ui_tower_level = %TowerLevel
@onready var ui_tower_damage = %TowerDamage
@onready var ui_tower_attack_rate = %TowerAttackRate 


func _ready():
	info_window.hide()
	GlobalSignals.enable_tower_ui.connect(show_tower_ui)
	
	
func show_tower_ui(tower_name: String, tower_cost: int, tower_level: int, tower_damage: float, tower_attack_rate: float):
	ui_tower_name.text = str(tower_name)
	ui_tower_cost.text = "Cost: " + str(tower_cost)
	ui_tower_level.text = "Tower Level: " + str(tower_level)
	ui_tower_damage.text = "Tower Damage: " +str(tower_damage)
	ui_tower_attack_rate.text = "Tower Attack Rate: " + str(tower_attack_rate)
	info_window.show()


func _on_close_tower_info_pressed():
	self.queue_free()
