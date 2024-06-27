extends Node

signal stop_spawning_enemies
signal wave_start
#Wave end isn't used yet, because nothing is happening at the spawner when the wave ends
signal wave_end
signal place_tower(tower_type: PackedScene)
signal towers_are_overlapping
signal towers_not_overlapping
signal create_tower_ui
signal delete_tower_ui
signal enable_tower_ui(tower_name: String, tower_cost: int, tower_level: int, tower_damage: float, tower_attack_rate: float)
