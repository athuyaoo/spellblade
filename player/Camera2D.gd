extends Camera2D
export (int)var max_offset = 10

func _process(delta):
	var distance = get_local_mouse_position() * 0.1
	offset = distance.clamped(max_offset)