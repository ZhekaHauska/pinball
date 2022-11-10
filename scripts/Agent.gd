extends Spatial

export var speed = 1.0
var direction = Vector3.FORWARD

func _physics_process(delta):
	if Input.is_action_pressed("turn_right"):
		rotation.y += 0.01
	if Input.is_action_pressed("turn_left"):
		rotation.y -= 0.01
	if Input.is_action_just_pressed("fire"):
		direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
		get_node("../Ball").apply_central_impulse(direction * speed)
