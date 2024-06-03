extends PathFollow2D

@export var speed : float


func _process(delta):
	progress_ratio += speed * delta
