extends State

var velocity := Vector2()
var dash_direction 
var dash_position
export(float) var dash_time = 0.1
export(float) var dash_speed = 600

func enter():
	owner.get_node("Trail").show()
	dash_direction = owner.get_local_mouse_position().normalized()
	velocity = dash_direction * dash_speed
	owner.update_side(dash_direction)
	owner.animate(owner.side + "dash")
	yield(get_tree().create_timer(dash_time), "timeout")
	owner.get_node("Trail").hide()
	velocity *= 0
	

func update(delta):
	owner.move_and_slide(velocity)
	
func _on_animation_finished(anim_name):
	emit_signal("finished", "previous")
