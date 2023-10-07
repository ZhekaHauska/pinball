extends Spatial

export var magnitude = 1.0
var reward = 0.0
var terminated = false
var direction = Vector3.FORWARD
signal magnitude_changed
signal angle_changed
signal got_reward

func _input(event):
	if Input.is_action_pressed("turn_right"):
		rotation.y += 0.01
		emit_signal("angle_changed", rotation.y)
	if Input.is_action_pressed("turn_left"):
		rotation.y -= 0.01
		emit_signal("angle_changed", rotation.y)		
	if Input.is_action_pressed("increase_impulse"):
		magnitude += 0.1
		emit_signal("magnitude_changed", magnitude)
	if Input.is_action_pressed("decrease_impulse"):
		magnitude -= 0.1
		if magnitude < 0:
			magnitude = 0
		emit_signal("magnitude_changed", magnitude)
	
	if Input.is_action_just_pressed("fire"):
		direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		get_node("../Ball").apply_central_impulse(direction * magnitude)

func act(angle, magnitude):
	direction = Vector3.FORWARD.rotated(Vector3.UP, angle)
	get_node("../Ball").apply_central_impulse(direction * magnitude)
