extends Node

var loot_drops: Dictionary = {
	1: 20000, #common
	2: 1000, #uncommon
	3: 500, #rare
	4: 250, #epic
	5: 150, #legendary
	6: 100, #mythic
	7: 50, #arcane
	8: 25, #godly
	9: 10 #blackhole
}



var num_items_to_spawn: int = 100000

func _ready():
	for i in range(50):
		get_loot_drop_chance()

func get_loot_drop_chance():
	var my_loot: Dictionary = {
	"common": 0,
	"uncommon": 0,
	"rare": 0,
	"epic": 0,
	"legendary": 0,
	"mythic": 0,
	"arcane": 0,
	"godly": 0,
	"blackhole": 0
	}
	var init_weight_sum: int = 0
	var sum_of_weight = aggregate_choice_weights(init_weight_sum)
	for i in range(num_items_to_spawn):
		var item_drop_id: int = pick_rand_loot_drop(sum_of_weight)
		var item_rarity: String = item_mapping(item_drop_id)
		my_loot[item_rarity] += 1
	print(my_loot)

func aggregate_choice_weights(sum_of_weight) -> int:
	for loot in loot_drops:
		sum_of_weight += loot_drops[loot]
	print(sum_of_weight)
	return sum_of_weight

func pick_rand_loot_drop(sum_of_weight: int) -> int:
	var rand_num: int = randi_range(1, sum_of_weight)
	
	for loot in loot_drops:
		if(rand_num <= loot_drops[loot]):
			return loot
		rand_num -= loot_drops[loot]
	return loot_drops.keys().back()

func item_mapping(item_id: int) -> String:
	match item_id:
		1:
			return "common"
		2:
			return "uncommon"
		3:
			return "rare"
		4:
			return "epic"
		5:
			return "legendary"
		6:
			return "mythic"
		7:
			return "arcane"
		8:
			return "godly"
		9:
			return "blackhole"
	return "oops"
