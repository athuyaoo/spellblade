extends State

var attack_direction = Vector2()
const ANIMATION = "attack"
var speed = 0
onready var move_speed = get_node("../Passive/Move").MAX_SPEED

func enter():
	attack_direction = (owner.get_global_mouse_position() 
						- owner.position).normalized()
	owner.update_side(attack_direction)
	owner.animate(owner.side + ANIMATION)
	attack_dash()

func update(delta):
	owner.move_and_slide(speed * attack_direction)

func attack_dash():
	var tween = owner.get_node("Tween")
	tween.interpolate_property(self, "speed", move_speed , 0, 0.1,
			Tween.TRANS_QUINT,Tween.EASE_IN)
	tween.start()

func _on_animation_finished(anim_name):
	emit_signal("finished", "previous")