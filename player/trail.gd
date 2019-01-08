extends Node

var point
export(int) var trail_length
onready var line = $Line2D
var visible


func _process(_delta):
	if visible:
		point = owner.global_position
		line.add_point(point)
#		while line.get_point_count() > trail_length:
#			line.remove_point(0)
	elif line.get_point_count() != 0:
		line.remove_point(0)

func hide():
	visible = false

func show():
	visible = true