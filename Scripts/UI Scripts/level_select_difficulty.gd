extends Control
class_name LevelSelectDifficulty

@onready var level_name_preview = %LevelNamePreview
@onready var level_image = %LevelImage
@onready var close_ui_button = %CloseUIButton
@onready var easy_button = %EasyButton
@onready var medium_button = %MediumButton
@onready var hard_button = %HardButton
@onready var level_path

func _ready():
	close_ui_button.connect("pressed", close_select_diff_ui)
	easy_button.connect("pressed", start_level_on_easy)
	medium_button.connect("pressed", start_level_on_medium)
	hard_button.connect("pressed", start_level_on_hard)

func setup_ui_info(level_name: String, level_image_preview: CompressedTexture2D):
	level_name_preview.text = level_name
	level_image.texture = level_image_preview
	
func setup_level_scene(scene_path: String):
	level_path = scene_path
	
func close_select_diff_ui():
	self.queue_free()

func start_level_on_easy():
	GameManager.level_difficulty = "Easy"
	get_tree().change_scene_to_file(level_path)

func start_level_on_medium():
	GameManager.level_difficulty = "Medium"
	get_tree().change_scene_to_file(level_path)
	
func start_level_on_hard():
	GameManager.level_difficulty = "Hard"
	get_tree().change_scene_to_file(level_path)
