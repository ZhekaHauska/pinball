extends Area

export var strength = 1.0
export var frequency = 2.0
export var reward = 0.0
export var terminal = false

var delay = 0.0
var attracted_body = null

func _process(delta):
	if attracted_body:
		if delay >= 1/frequency:
			var direction = - attracted_body.linear_velocity.normalized()
			attracted_body.apply_central_impulse(direction * strength)
			
			direction = translation - attracted_body.translation
			attracted_body.apply_central_impulse(direction * strength)
			delay = 0.0
		else:
			delay += delta

func _on_Attractor_body_entered(body):
	$AnimationPlayer.play("interact")
	attracted_body = body
	
	var agent = get_node('../../Agent')
	agent.reward = reward
	agent.emit_signal('got_reward', agent.reward)
	
	if terminal:
		get_node('../../../Env').terminate = true

func _on_Attractor_body_exited(body):
	$AnimationPlayer.play("RESET")
	attracted_body = null
	
	var agent = get_node('../../Agent')
	agent.reward = 0
	agent.emit_signal('got_reward', agent.reward)
