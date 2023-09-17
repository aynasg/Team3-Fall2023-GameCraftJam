extends Enemy

export var state := states.ATTACK

func _physics_process(delta):
	# Updating velocity
	if state == states.ATTACK:
		velocity = move_and_slide(velocity, Vector2.UP)
