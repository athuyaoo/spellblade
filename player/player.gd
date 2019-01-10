extends KinematicBody2D

var side = "down_"


func _ready():
	$"Pivot/Attack/CollisionPolygon2D".disabled = true
	# Register event to monitor if joystick connected or disconnected
	Input.connect("joy_connection_changed", self,"joy_con_changed")


func joy_con_changed(deviceid,isConnected):
	if isConnected:
		print("Joystick " + str(deviceid) + " connected")
	if Input.is_joy_known(0):
		print("Recognized and compatible joystick")
		print(Input.get_joy_name(0) + " device connected")
	else:
		print("Joystick " + str(deviceid) + " disconnected")

func animate(new_animation):
	$AnimationPlayer.play(new_animation)

func update_side(direction):
	var new_side
	if direction.y > 0:
		new_side = "down_"
	elif direction.y < 0:
		new_side = "up_"
	if direction.x != 0 and abs(direction.x) >= abs(direction.y):
		$Pivot.scale.x = 1 if direction.x > 0 else -1
		new_side = "side_" 
	if direction and new_side != side:
		side = new_side
		return true