@tool
extends Control

@export var world_index : int = 1
@export var world_name : String = ""
@export var world_preview : CompressedTexture2D
@export var level_select_packed : PackedScene
@onready var level_select_scene : LevelSelect = level_select_packed.instantiate()
@onready var world_image = %WorldImage

func _ready():
	$Label.text = "World " + str(world_index)
	if world_name not in GameManager.game_state.unlocked_worlds:
		print(world_name + " not in game")
		world_image.self_modulate = Color(Color.GRAY, 0.5)
	if world_preview:
		world_image.texture = world_preview
		
func _process(_delta) -> void:
	if Engine.is_editor_hint():
		$Label.text = "World " + str(world_index)
