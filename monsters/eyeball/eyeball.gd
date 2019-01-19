extends KinematicBody2D

enum {IDLE, ATTACK, MOVE, JUMP, PURSUE, SHIFT, WANDER, HURT, DIE}

var max_speed = 100
var max_force = 0.1

onready var health_label = $Health
onready var player = $"../Player"
onready var anim_player = $AnimationPlayer


var speed = 0
var push_direction
var destination
var state = IDLE
var velocity = Vector2()
var attack_count = 0
var jump_position
var attack_range = 40
var health = 2

func _ready():
	health_label.text = str(health)
	_change_state(IDLE)

func _change_state(new_state):
	match new_state:
		IDLE:
			anim_player.play("idle")
		MOVE, JUMP:
			velocity = velocity * 0
			anim_player.play("move")
			new_destination(player)
			var direction = destination - position
			if new_state == JUMP:
				while direction.length() < 4 and destination.distance_to(player.position) < 10:
					new_destination(player)
		ATTACK:
			anim_player.play("attack")
			attack_count = 0
			get_attack_angle(player)
		HURT:
			push_direction = (global_position - player.position).normalized()
			$Position2D/Laser/AttackEffect.modulate.a = 0
			anim_player.play("hurt")
			push()
		DIE:
			push_direction = (global_position - player.position).normalized()
			$Position2D/Laser/AttackEffect.modulate.a = 0
			$Position2D/Hitbox.set_deferred("monitoring",false)
			anim_player.play("die")
			add_collision_exception_with(player)
			health_label.visible = false
			z_index = -1
			push()

			
	state = new_state
	

func _physics_process(delta):
	if not player:
		velocity = flock()
		move_and_slide(velocity)
		return
	var current_state = state
	match current_state:
		IDLE:
			if position.distance_to(player.position) < 50:
				_change_state(MOVE)
		MOVE:
			if player.position.distance_to(destination) > 30:
				new_destination(player)
			if position.distance_to(destination) < 20:
				_change_state(ATTACK)
			velocity = follow(destination) + flock()
			velocity = velocity.normalized()*max_speed
			move_and_slide(velocity)
		JUMP:
			if position.distance_to(destination) < 1:
				_change_state(ATTACK)
			velocity = follow(destination)
			move_and_slide(velocity)
		HURT, DIE:
			move_and_slide(push_direction * speed)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		attack_count += 1
		if position.distance_to(player.position) > 30:
			_change_state(MOVE)
		elif attack_count > 0:
			_change_state(MOVE)
		else:
			anim_player.play("attack")
			get_attack_angle(player)
	if anim_name == "hurt":
		_change_state(MOVE)

# Makes the eyeball dash a bit
func push():
	var tween = get_node("Tween")
	tween.interpolate_property(self, "speed", 100, 0, 0.1,
			Tween.TRANS_QUINT,Tween.EASE_IN)
	tween.start()

# Finds a random spot past the player
func new_destination(target):
	randomize()
	var side = 0
	var vector_to_target = target.position - position
	var normal = vector_to_target.normalized().tangent()
	while side == 0:
		side = sign(rand_range(-1, 1))
	var distance = rand_range(16, attack_range)
	var x = vector_to_target + normal * side  * distance
	destination = position + x
	

# Finds a random spot around player in a circular area
func circle_destination(target):
	var point = (10 * sqrt(randf())) + 20
	var theta = randf() * TAU
	var x = point * cos(theta)
	var y = point * sin(theta)
	destination = target.position + Vector2(x,y)

func steer(destination):
	var desired_velocity = (destination - position).normalized() * max_speed
	var steer_force = (desired_velocity - velocity)
	var target_velocity = (velocity + steer_force/5)
	return target_velocity

func follow(destination):
	var distance_to_target = position.distance_to(destination)
	var desired_velocity = (destination - position).normalized() * max_speed
	if distance_to_target < 50:
		desired_velocity *= (distance_to_target / 50)*0.9 + 0.1
	var steer_force = (desired_velocity - velocity)
	var target_velocity = (velocity + steer_force/5)
	return target_velocity.clamped(max_speed)

func get_attack_angle(body):
	var attack_angle = (body.position-position).angle()
	$Position2D/Laser.rotation_degrees = rad2deg(attack_angle)

func compute_alignment():
	var velocity = Vector2(0,0)
	var neighbour_count = 0
	for eyeball in get_tree().get_nodes_in_group("eyeball"):
		if eyeball != self:
			if eyeball.position.distance_to(position) < 50:
				velocity += eyeball.velocity
				neighbour_count += 1
	if neighbour_count == 0:
		return velocity
	velocity /= neighbour_count
	return velocity.normalized()

func compute_cohesion():
	var velocity = Vector2(0,0)
	var neighbour_count = 0
	for eyeball in get_tree().get_nodes_in_group("eyeball"):
		if eyeball != self:
			if eyeball.position.distance_to(position) < 50:
				velocity += eyeball.position
				neighbour_count += 1
	if neighbour_count == 0:
		return velocity
	velocity /= neighbour_count
	velocity = velocity - position
	return velocity.normalized()

func compute_separation():
	var velocity = Vector2(0,0)
	var neighbour_count = 0
	for eyeball in get_tree().get_nodes_in_group("eyeball"):
		if eyeball != self:
			if eyeball.position.distance_to(position) < 500:
				velocity = eyeball.position - position
				neighbour_count += 1
	if neighbour_count == 0:
		return velocity
	velocity /= neighbour_count
	velocity *= -1
	return velocity.normalized()

func flock():
	var alignment = compute_alignment()
	var cohesion = compute_cohesion()
	var separation = compute_separation()
	
	var velocity = separation
	velocity = velocity.normalized() * max_speed * 0.1
	return velocity

func _on_Hitbox_area_entered(area):
	if area.owner == player and area.name == "Attack":
		health -= 1
		health_label.text = str(health)
		if health > 0:
			_change_state(HURT)
		elif state != DIE:
			_change_state(DIE)