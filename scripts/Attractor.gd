extends Area

export var strength = 1.0
export var frequency = 2.0

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

func _input(event):
	if Input.is_action_just_pressed("reset"):
		attracted_body = null

func _on_Attractor_body_entered(body):
	$AnimationPlayer.play("interact")
	attracted_body = body

func _on_Attractor_body_exited(body):
	$AnimationPlayer.play("RESET")
	attracted_body = null


