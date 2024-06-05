extends PathFollow2D

#var total_time = 4
#var running_time = 0
@export var speed : float

func _ready():
	pass

func _process(delta):
	set_progress_ratio(get_progress_ratio() + (speed/100.0) * delta)
	#running_time += delta
	#if running_time >= total_time: running_time = 0
	#$PathFollow2D.unit_offset = lerp(0, 1, running_time / total_time)
