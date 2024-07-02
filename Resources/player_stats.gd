class_name Player
extends Resource

@export var coins : int
@export var tower_levels : Dictionary
@export var regular_tower_level : int
@export var shotgun_tower_level : int
@export var machinegun_tower_level : int

func _init(coin : int = 1, tower_lvl : Dictionary = {"RegularTowerLevel": 1, "ShotgunTowerLevel" : 1, "MachinegunTowerLevel": 1}):
	coins = coin
	tower_levels = tower_lvl
	 
