extends "res://player/states/passive/passive.gd"

const ANIMATION = "walk"
export(int) var MAX_SPEED = 120
export(float) var START_TIME = 0.4
var speed

func enter():
	var move_direction = get_movement_direction()
	owner.update_side(move_direction)
	owner.animate(owner.side + ANIMATION)
	accelerate()

func update(_delta):
	var move_direction = get_movement_direction()
	if not move_direction:
		emit_signal("finished", "idle")
	if owner.update_side(move_direction):
		owner.animate(owner.side + ANIMATION)
	var velocity = move_direction.normalized() * speed
	owner.move_and_slide(velocity)

func accelerate():
	var tween = owner.get_node("Tween")
	tween.interpolate_property(self, "speed", 0, MAX_SPEED, START_TIME,
			Tween.TRANS_CUBIC,Tween.EASE_OUT)
	tween.start()