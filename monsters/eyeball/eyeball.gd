
extends KinematicBody2D

enum {IDLE, ATTACK, MOVE, JUMP, PURSUE, SHIFT, WANDER, HURT, DIE}

var max_speed = 150
var max_force = 0.1

onready var player = $"../Player"
onready var anim_player = $AnimationPlayer

var destination
var player_position
var state
var velocity = Vector2()
var attack_count = 0
var jump_position
var attack_range = 40

func _ready():
	_change_state(MOVE) if player != null else _change_state(IDLE)

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
	state = new_state

func _physics_process(delta):
	if not player:
		velocity = flock()
		move_and_slide(velocity)
		return
	var current_state = state
	match current_state:
		MOVE:
#			if player.position.distance_to(destination) > 30:
#				new_destination(player)
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
	return target_velocity

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