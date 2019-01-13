extends Position2D


func _process(delta):
	var distance = get_parent().get_local_mouse_position() * 0.3
	if distance.length() < 20:
		distance = distance.normalized() * 20
	position = distance
	