extends Spatial

export var pos = Vector2(0, 0)
export var angle = 0.0
export var length = 1.0

func _ready():
	var y = translation.y
	translation = Vector3(
		pos.x,
		y,
		pos.y
	)
	rotation_degrees = Vector3(
		0,
		angle,
		0
	)
	$CSGBox.depth = length
