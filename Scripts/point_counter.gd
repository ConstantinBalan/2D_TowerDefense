extends Node

signal point_counted()

func count_point():
	point_counted.emit()

