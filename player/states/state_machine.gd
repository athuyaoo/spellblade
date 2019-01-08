extends Node

signal state_changed(state)

export(NodePath) var START_STATE
var states_map = {}

var states_stack = []
var current_state = null

func _ready():
	ready_states(self)
	initialize(START_STATE)
	print(states_map)

func ready_states(states):
	for child_state in states.get_children():
		if child_state.get_children() == []:
			states_map[child_state.name.to_lower()] = child_state
			child_state.connect("finished", self, "_change_state")
		elif child_state.get_children() != []:
			ready_states(child_state)

func initialize(start_state):
	states_stack.push_front(get_node(start_state))
	current_state = states_stack[0]
	current_state.enter()

# current state handle animations, updates, and inputs.
func _input(event):
	current_state.handle_input(event)

func _physics_process(delta):
	current_state.update(delta)

func _on_animation_finished(anim_name):
	current_state._on_animation_finished(anim_name)

func _change_state(state_name):
	if state_name in ["dash", "attack"]:
		states_stack.push_front(states_map[state_name])
	current_state.exit()
	
	# updates the state stack
	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]
	
	current_state = states_stack[0]
	emit_signal("state_changed", current_state)
	current_state.enter()