extends Enemy

onready var SpriteNode := $Sprite
onready var LineOfSight := $Raycast
onready var IdleTimer := $IdleTimer
onready var MoveTimer := $MoveTimer
#onready var AttackRange := $AttackRange

# Movement
export var movement_speed := 100
export var acceleration := 5 

export var state := states.IDLE

export var min_move_time := 0.5
export var max_move_time := 5
export var min_idle_time := 5
export var max_idle_time := 15
export var move_towards_player_bias = 4

var just_entered_idle := false
var just_entered_move := false
var should_move := false
var can_see_player := false

func _ready():
	MoveTimer.connect("timeout", self, "_move_timer_up")
	IdleTimer.connect("timeout", self, "_idle_timer_up")

func _process(delta):
	# Simple state machine
	match state:
		states.IDLE:
			idle_state()
		states.MOVE:
			move_state()
		states.ATTACK:
			attack_state()
	
	state_logic()
	
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

func state_logic():
	if can_see_player:
		should_move = false
		just_entered_idle = true
		just_entered_move = false
		
		state = states.ATTACK
	elif should_move:
		state = states.MOVE
	else:
		just_entered_move = true
		
		state = states.IDLE

func idle_state():
	if just_entered_idle:
		reset_idle_timer()
		IdleTimer.start()
	
	just_entered_idle = false

func move_state():
	if just_entered_move:
		reset_move_timer()
		MoveTimer.start()
		
		if int(rand_range(1, move_towards_player_bias)) == 1:
			direction *= -1
		else:
			face_player()
		
	
	velocity.x += acceleration * direction
	just_entered_move = false

func attack_state():
	face_player()

# Resets the idle timer to a random float between the min and max idle times
func reset_idle_timer():
	var wait_time = clamp(randf() * max_idle_time, min_idle_time, max_idle_time)
	IdleTimer.wait_time = wait_time

func reset_move_timer():
	var wait_time = clamp(randf() * max_move_time, min_move_time, max_move_time)
	MoveTimer.wait_time = wait_time

func _idle_timer_up():
	print("You have been idle for too long")
	should_move = true

func _move_timer_up():
	should_move = false
	just_entered_idle = true
	just_entered_move = false

func face_player():
	var direction_to_player = position.direction_to(Game.player_position).normalized()
	if direction_to_player.x > 0:
		direction = 1
	else:
		direction = -1
