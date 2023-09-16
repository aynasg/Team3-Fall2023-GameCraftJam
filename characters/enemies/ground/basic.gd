extends Enemy

onready var SpriteNode := $Sprite
onready var LineOfSight := $Raycast
onready var AttackRange := $AttackRange

# Movement
export var movement_speed := 100
export var acceleration := 5 

export var state := states.IDLE

var can_see_player := false

func _process(delta):
	# Simple state machine
	match state:
		states.IDLE:
			idle_state()
		states.FOLLOW:
			follow_state()
		states.ATTACK:
			attack_state()
	
	# State logic
	if can_see_player:
		if player_in_attack_range():
			state = states.ATTACK
		else:
			state = states.FOLLOW
	else:
		state = states.IDLE
		
	
	# Handles velocity
	velocity.x *= 0.91
	velocity.x = clamp(velocity.x, -movement_speed, movement_speed)
	
	# Makes the sprite face the direction of the enemy
	if direction == 1:
		SpriteNode.flip_h = false
	else:
		SpriteNode.flip_h = true

func _physics_process(delta):
	# Updating velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#Line of Sight Logic
	# Casting the raycast to the player's position
	LineOfSight.cast_to = -2.2 * (position - Game.player_position)
	
	if LineOfSight.is_colliding() and LineOfSight.get_collider().name == "Player":
		can_see_player = true
	else:
		can_see_player = false

func idle_state():
	pass

func follow_state():
	face_player()
	velocity.x += acceleration * direction

func attack_state():
	face_player()

func player_in_attack_range() -> bool:
	var bodies = AttackRange.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			return true
	return false

func face_player():
	var direction_to_player = position.direction_to(Game.player_position).normalized()
	
	if direction_to_player.x > 0:
		direction = 1
	else:
		direction = -1
