extends Area

export var angles = [0, 30, -30]
export var strength = 1


func _on_ForceArea_body_entered(body):
	$AnimationPlayer.play("interact")
	var angle = angles[randi() % angles.size()]
	var direction = Vector3.FORWARD.rotated(Vector3.UP, angle)
	body.apply_central_impulse(direction * strength)
