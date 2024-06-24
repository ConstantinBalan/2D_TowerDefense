extends Node2D

var coins : int
var regular_tower_level : int
var shotgun_tower_level : int
var machinegun_tower_level : int


func _ready(player_coins = 10, reg_tow_lvl = 1, shot_tow_lvl = 2, mg_tow_lvl = 3):
	coins = player_coins
	regular_tower_level = reg_tow_lvl
	shotgun_tower_level = shot_tow_lvl
	machinegun_tower_level = mg_tow_lvl
