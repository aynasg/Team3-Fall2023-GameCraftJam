extends KinematicBody2D

# -----| Player Constant Declarations |------

const MAX_X_SPEED = 400; #unit/sec
const MAX_Y_SPEED = 400; #unit/sec
const ACCELERATION = MAX_X_SPEED/0.1; #unit/sec^2

# -----| On Ready |-----
onready var jumping : bool = false;
onready var canJump : bool = true;
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
	
	if Input.is_action_pressed("player_jump") and canJump:
		dv -= Vector2(0, MAX_Y_SPEED);
		canJump = false;
	else:
		dv += Vector2(0, delta*WorldConst.GRAVITY);
		canJump = true;
	
	velocity += dv;
	if abs(velocity.x) > MAX_X_SPEED:
		velocity.x = MAX_X_SPEED*sign(velocity.x);
	if abs(velocity.y) > MAX_Y_SPEED:
		velocity.y = MAX_Y_SPEED*sign(velocity.y);
	
	print(input, velocity);
	
	move_and_slide(velocity, Vector2.UP);
	pass
