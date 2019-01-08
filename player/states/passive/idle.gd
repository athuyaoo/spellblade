extends "res://player/states/passive/passive.gd"

const ANIMATION = "idle"

func enter():
	owner.animate(owner.side + ANIMATION)

func update(delta):
	var movement_direction = get_movement_direction()
	if movement_direction:
		emit_signal("finished", "move")