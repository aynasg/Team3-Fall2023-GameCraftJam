extends KinematicBody2D

# -----| Player Constant Declarations |------

const MAX_X_SPEED = 400; #unit/sec
const MAX_Y_SPEED = 1000; #unit/sec
const JUMP_SPEED = -500; #unit/sec
const ACCELERATION = MAX_X_SPEED/0.1; #unit/sec^2
const GRAVITY = 2000; #unit/sec^2
const JUMP_HOLD_GRAVITY_FACTOR = 0.33;
const FAST_FALL_GRAVITY_FACTOR = 3;

# -----| On Ready |-----
onready var onGround : bool = false;
onready var doubleJumpAvailable : bool = true;
onready var fastFalling : bool = false;
onready var velocity : Vector2 = Vector2.ZERO;

func _ready():
	pass # Replace with function body.

# -----| Each Frame |-----

func _physics_process(delta):
	var input = 0;
	if Input.is_action_pressed("player_right"):
		input += 1;
	if Input.is_action_pressed("player_left"):
		input -= 1;
	
	var dv = Vector2.ZERO;
	if input == 0:
		dv += Vector2(min(abs(velocity.x), delta*ACCELERATION), 0);
		if velocity.x > 0:
			dv *= -1;
	else:
		dv += Vector2(delta*ACCELERATION, 0)*input;
		if sign(dv.x) != sign(velocity.x):
			dv *= 2;
	
	if Input.is_action_just_pressed("player_fast_fall"):
		fastFalling = true;
	
	if Input.is_action_just_pressed("player_jump") and onGround:
		velocity.y = JUMP_SPEED;
		fastFalling = false;
	elif Input.is_action_just_pressed("player_jump") and doubleJumpAvailable:
		velocity.y = JUMP_SPEED;
		doubleJumpAvailable = false;
		fastFalling = false;
	elif fastFalling:
		dv += Vector2(0, FAST_FALL_GRAVITY_FACTOR*delta*GRAVITY);
	elif Input.is_action_pressed("player_jump") or velocity.y > 0:
		dv += Vector2(0, JUMP_HOLD_GRAVITY_FACTOR*delta*GRAVITY);
	else:
		dv += Vector2(0, delta*GRAVITY);
	
	velocity += dv;
	if abs(velocity.x) > MAX_X_SPEED:
		velocity.x = MAX_X_SPEED*sign(velocity.x);
	if abs(velocity.y) > MAX_Y_SPEED:
		velocity.y = MAX_Y_SPEED*sign(velocity.y);
	
	print(input, " ", Input.is_action_pressed("player_jump"), " ", fastFalling, " ", velocity);
	
	var real_velocity = move_and_slide(velocity, Vector2.DOWN);
	
	onGround = real_velocity.y < velocity.y;
	if onGround:
		doubleJumpAvailable = true;
		fastFalling = false;
	
	pass
