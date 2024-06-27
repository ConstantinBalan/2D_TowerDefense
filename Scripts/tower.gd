extends Node2D
@export var projectile_scene : PackedScene
@export var attack_rate : float
@export var tower_level : int = 0
@export var tower_damage : float
@export var placed = false
@export var tower_type_name : String
@export var tower_cost : int

var bullet_amount = 3
var targets : Array
var cur_target = null
var can_attack = true
var was_recently_placed = false
var can_click_ui = false
const PIXEL_OPERATOR_8 = preload("res://Assets/PixelOperator8.ttf")

func _ready():
	if is_in_group("regular_tower"):
		tower_level = PlayerStats.regular_tower_level
	if is_in_group("shotgun_tower"):
		tower_level = PlayerStats.shotgun_tower_level
	if is_in_group("machinegun_tower"):
		tower_level = PlayerStats.machinegun_tower_level
	var label_pos = Vector2(-50, -30)
	var name_label : Label = Label.new()
	name_label.uppercase = true
	name_label.position = label_pos
	name_label.add_theme_font_override("PixelFont",PIXEL_OPERATOR_8)
	name_label.add_theme_font_size_override("PixelFont", 8)
	name_label.text = self.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(name_label)

func _process(delta):
	if was_recently_placed and can_click_ui == false:
		recently_placed()
	if cur_target and cur_target.is_inside_tree() and can_attack:
		shoot_bullet(38.0,tower_damage)
		can_attack = false
		await get_tree().create_timer(attack_rate).timeout
		can_attack = true
	#if cur_target:
	#	_on_timer_timeout(cur_target)

func shoot_bullet(speed: float, damage: float):
	if placed:
		var projectile = projectile_scene
		var bullet = projectile.instantiate()
		bullet.speed = speed
		bullet.damage = damage
		bullet.target = cur_target
		bullet.global_position = get_parent().position
		self.add_child(bullet)

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		if body not in targets:
			targets.append(body)
			if not cur_target:
				cur_target = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("enemy"):
		if body in targets:
			targets.erase(body)
			if body == cur_target:
				cur_target = null
				if targets.size() > 0:
					cur_target = targets[0]

func _on_tower_space_area_entered(area):
	print("body entered")
	if area.is_in_group("tower_hitbox"):
		print("towers are overlapping, can't place")
		GlobalSignals.towers_are_overlapping.emit()

func _on_tower_space_area_exited(area):
	if area.is_in_group("tower_hitbox"):
		print("towers no longer overlapping")
		GlobalSignals.towers_not_overlapping.emit()

func recently_placed():
	await get_tree().create_timer(0.1).timeout
	can_click_ui = true

#func _on_tower_ui_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.pressed and can_click_ui:
#		print("Tower should fill in info")
#		GlobalSignals.create_tower_ui.emit()
#		GlobalSignals.emit_signal("enable_tower_ui", tower_type_name, tower_cost, tower_level, tower_damage, attack_rate)
