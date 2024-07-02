class_name Tower
extends Node2D

#Exported variables
#---------------------------
@export var projectile_scene : PackedScene
@export var tower_sprite: Texture2D
@export var level : int = 0
@export var attack_rate : float
@export var damage : float
@export var placed = false
@export var type : String
@export var cost : int
@export var name_label : Label 
#---------------------------

var bullet_amount = 3
var targets : Array = []
var cur_target = null
var can_attack : bool = true
var was_recently_placed = false
var can_click_ui = false
var sprite: Sprite2D

const PIXEL_OPERATOR_8 = preload("res://Assets/PixelOperator8.ttf")

func _init(data: Dictionary = {}):
	type = data.get("type", "regular")
	level = data.get("level", 1)
	cost = data.get("cost", 100)
	_update_stats()

func _ready():
	_setup_name_label()
	_setup_sprite()

func _setup_name_label():
	var label_pos = Vector2(-50, -30)
	name_label = Label.new()
	name_label.uppercase = true
	name_label.position = label_pos
	name_label.add_theme_font_override("PixelFont",PIXEL_OPERATOR_8)
	name_label.add_theme_font_size_override("PixelFont", 8)
	name_label.text = self.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(name_label)

func _setup_sprite():
	sprite = Sprite2D.new()
	sprite.texture = tower_sprite
	add_child(sprite)


func _update_stats():
	match type:
		"Regular":
			damage = 10.0 + (level - 1) * 2.0
			attack_rate = 1.0 + (level - 1) * 0.1
		"Shotgun":
			damage = 30.0 + (level - 1) * 5.0
			attack_rate = 0.5 + (level - 1) * 0.05
		"Machine Gun":
			damage = 7.0 + (level - 1) * 5.0
			attack_rate = 0.3 + (level - 1) * 0.05

func _process(delta):
	if was_recently_placed and can_click_ui == false:
		recently_placed()
	if cur_target and cur_target.is_inside_tree() and can_attack:
		shoot_bullet(38.0,damage)
	#if cur_target:
	#	_on_timer_timeout(cur_target)

func upgrade_tower() -> void:
	level += 1
	_update_stats()

func shoot_bullet(speed: float, damage: float) -> void:
	if placed:
		var projectile = projectile_scene
		var bullet = projectile.instantiate()
		bullet.speed = speed
		bullet.damage = damage
		bullet.target = cur_target
		bullet.global_position = get_parent().position
		add_child(bullet)
		can_attack = false
		get_tree().create_timer(attack_rate).timeout.connect(func(): can_attack = true)


func get_info() -> Dictionary:
	return {
		"type": type,
		"cost": cost,
		"level": level,
		"damage": damage,
		"attack_rate": attack_rate
	}



func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("enemy"):
		if body not in targets:
			targets.append(body)
			if not cur_target:
				cur_target = body

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group("enemy"):
		if body in targets:
			targets.erase(body)
			if body == cur_target:
				cur_target = null
				if targets.size() > 0:
					cur_target = targets[0]

func _on_tower_space_area_entered(area) -> void:
	print("body entered")
	if area.is_in_group("tower_hitbox"):
		print("towers are overlapping, can't place")
		GlobalSignals.towers_are_overlapping.emit()

func _on_tower_space_area_exited(area) -> void:
	if area.is_in_group("tower_hitbox"):
		print("towers no longer overlapping")
		GlobalSignals.towers_not_overlapping.emit()

func recently_placed() -> void:
	await get_tree().create_timer(0.1).timeout
	can_click_ui = true

#func _on_tower_ui_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.pressed and can_click_ui:
#		print("Tower should fill in info")
#		GlobalSignals.create_tower_ui.emit()
#		GlobalSignals.emit_signal("enable_tower_ui", tower_type_name, tower_cost, tower_level, tower_damage, attack_rate)
