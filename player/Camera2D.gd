extends Camera2D

func _process(delta):
	offset = get_local_mouse_position() * 0.1