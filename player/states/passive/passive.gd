# Handles player when in the passive state, e.g. moving and idling
extends "../state.gd"

# movement direction taken from the movement keys.
func get_movement_direction():
	var right_key = Input.is_action_pressed("move_right")
	var left_key = Input.is_action_pressed("move_left")
	var down_key = Input.is_action_pressed("move_down")
	var up_key = Input.is_action_pressed("move_up")
	var input_direction = Vector2()
	input_direction.x = int(right_key) - int(left_key)
	input_direction.y = int(down_key) - int(up_key)
#	if Input.get_connected_joypads():
#		input_direction.x = Input.get_joy_axis(0, JOY_AXIS_0)
#		input_direction.y = Input.get_joy_axis(0, JOY_AXIS_1)
	return input_direction

func handle_input(event):
	if event.is_action_pressed("dash"):
		emit_signal("finished", "dash")
	if event.is_action_pressed("attack"):
		emit_signal("finished", "attack")