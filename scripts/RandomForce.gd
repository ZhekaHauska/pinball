extends Area

export var angles = [0, 30, -30]
export var strength = 1
export var reward = 0.0
export var terminal = false


func _on_ForceArea_body_entered(body):
	if body is StaticBody:
		return
		
	$AnimationPlayer.play("interact")
	
	var agent = get_node("../../Agent")
	agent.reward = reward
	agent.terminated = terminal
	agent.emit_signal('got_reward', agent.reward)
		
	var angle = angles[randi() % angles.size()]
	var direction = Vector3.FORWARD.rotated(Vector3.UP, angle)
	body.apply_central_impulse(direction * strength)


func _on_RandomForce_body_exited(body):
	var agent = get_node('../../Agent')
	agent.reward = 0
	agent.terminated = false
	agent.emit_signal('got_reward', agent.reward)
