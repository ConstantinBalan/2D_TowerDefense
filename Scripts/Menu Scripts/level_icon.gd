@tool
extends Control
class_name LevelIcon

@export var level_index : String = "1"
@export var level_image_preview : CompressedTexture2D
@export_file("*.tscn") var next_scene_path : String
@export var next_level_up : LevelIcon
@export var next_level_down : LevelIcon
@export var next_level_left : LevelIcon
@export var next_level_right : LevelIcon
@onready var level_image = $LevelImage

func _ready():
	$Label.text = "Level " + level_index
	if level_image_preview:
		level_image.texture = level_image_preview
	

func _process(_delta) -> void:
	if Engine.is_editor_hint():
		$Label.text = "Level " + level_index
