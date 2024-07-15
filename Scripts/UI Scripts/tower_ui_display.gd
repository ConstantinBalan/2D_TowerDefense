extends Node

@onready var info_window = $".."
@onready var ui_tower_name = %TowerName
@onready var tower_photo = %TowerPhoto
@onready var tower_wood_cost = %TowerWoodCost
@onready var tower_stone_cost = %TowerStoneCost
@onready var tower_gold_cost = %TowerGoldCost
@onready var ui_tower_level = %TowerLevel
@onready var ui_tower_damage = %TowerDamage
@onready var ui_tower_attack_rate = %TowerAttackRate 


func _ready():
	info_window.hide()
	GlobalSignals.enable_tower_ui.connect(show_tower_ui)
	print("tower ui created")
	
	
func show_tower_ui(tower_info : Dictionary):
	ui_tower_name.text = tower_info["type"]
	tower_wood_cost.text = "Wood: " + str(tower_info["wood_cost"])
	tower_stone_cost.text = "Stone: " + str(tower_info["stone_cost"])
	tower_gold_cost.text = "Gold: " + str(tower_info["gold_cost"])
	ui_tower_level.text = "Tower Level: " + str(tower_info["level"])
	ui_tower_damage.text = "Tower Damage: " +str(tower_info["damage"])
	ui_tower_attack_rate.text = "Tower Attack Rate: " + str(tower_info["attack_rate"])
	info_window.show()
