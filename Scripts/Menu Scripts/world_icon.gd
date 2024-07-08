@tool
extends Control

@export var world_index : int = 1
@export var level_select_packed : PackedScene = load("res://Scenes/Levels/Menus/grass_level_select.tscn")
@onready var level_select_scene : LevelSelect = level_select_packed.instantiate()

func _ready():
	$Label.text = "World " + str(world_index)
	

func _process(delta) -> void:
	if Engine.is_editor_hint():
		$Label.text = "World " + str(world_index)
