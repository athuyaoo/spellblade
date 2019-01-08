extends "state.gd"

var velocity = Vector2()
var dash_direction 
export(float) var dash_time = 0.1

func enter():
	owner.get_node("Trail").show()
	dash_direction = owner.get_global_mouse_position() - owner.position
	owner.update_side(dash_direction)
	owner.animate(owner.side + "idle")
	yield(get_tree().create_timer(dash_time), "timeout")
	owner.get_node("Trail").hide()
	emit_signal("finished", "previous")

func update(delta):
	owner.move_and_slide(dash_direction.normalized() * 600)
