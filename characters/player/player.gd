extends KinematicBody2D


# -----| Player Constant Declarations |------


const MAX_X_SPEED = 400; # unit/sec
const MAX_Y_SPEED = 1000; # unit/sec
const ACCELERATION = MAX_X_SPEED/0.1; # unit/sec^2
const NO_INPUT_DRAG = 0.5*ACCELERATION; # unit/sec^2
const TURN_AROUND_FACTOR = 2;

const JUMP_SPEED = -500; # unit/sec
const GRAVITY = 2000; # unit/sec^2
const JUMP_HOLD_GRAVITY_FACTOR = 0.33;
const FAST_FALL_GRAVITY_FACTOR = 3;

const ATTACK_DIST = 20; # units
const ATTACK_ACTIVE_TIME = 0.1; # sec
const ATTACK_TIMEOUT_TIME = 0.5; # sec

const ZIP_TIMEOUT_TIME = 1; # sec
const ZIP_STUN_TIME = 0.25; # sec
const ZIP_SLOW_FACTOR = 0.1;
const ZIP_DIST = 200;

# -----| On Ready |-----


onready var double_jump_available : bool = true;
onready var fast_falling : bool = false;
onready var velocity : Vector2 = Vector2.ZERO;
onready var attack_timeout : float = 0;
onready var mousePos : Vector2 = Vector2.ZERO;
onready var zip_timeout : float = 0;
onready var zip_stun : float = 0;
onready var zip_movement : Vector2 = Vector2.ZERO;
onready var zips_since_land : int = 0;


func _ready():
	# Hide graphics for Attack and Zip
	$Attack/Sprite.hide();
	$Zip/Line2D.hide();
	pass


# -----| Each Frame |-----


func _process(delta):
	check_for_attack(delta);
	check_for_zip(delta);
	update_velocity(delta);


func _physics_process(delta):
	# If zipping move the zip_movement instead of the velocity
	if zip_movement != Vector2.ZERO:
		move_and_slide(zip_movement/delta, Vector2.UP);
		zip_movement = Vector2.ZERO;
	# If in zip stun -> slow movement
	elif zip_stun > 0:
		move_and_slide(ZIP_SLOW_FACTOR*velocity, Vector2.UP);
	# Otherwise continue with standard velocity
	else:
		move_and_slide(velocity, Vector2.UP);


func check_for_attack(delta):
	# Start the attack timeout timer on attack, given that the attack isn't on timeout
	if Input.is_action_pressed("player_attack") && attack_timeout <= 0:
		attack_timeout = ATTACK_TIMEOUT_TIME;
		#$Attack.translate()
	# If the attack timeout > 0, reduce by time passed since last update
	elif attack_timeout > 0:
		attack_timeout -= delta;
	
	# Show/Hide the attack and enable the attack area for ATTACK_ACTIVE_TIME 
	# starting from initial input
	if ATTACK_TIMEOUT_TIME - attack_timeout < ATTACK_ACTIVE_TIME:
		$Attack/Sprite.show();
		$Attack.monitorable = true;
	else:
		$Attack/Sprite.hide();
		$Attack.monitorable = false;
	pass;


func check_for_zip(delta):
	# Start the attack timeout timer on attack, given that the attack isn't on timeout
	if Input.is_action_just_pressed("player_zip") && zip_timeout <= 0:
		zip_timeout = ZIP_TIMEOUT_TIME;
		zip_stun = ZIP_STUN_TIME;
		$Zip/Line2D.show();
		# If there is something to zip across, set the zip direction
		if not $Zip.get_overlapping_bodies().empty() and zips_since_land < 3:
			zip_movement = ZIP_DIST*Vector2(cos($Zip.rotation), sin($Zip.rotation));
			zip_timeout = 0;
			zips_since_land += 1;
	# If the attack timeout > 0, reduce by time passed since last update
	elif zip_timeout > 0 or zip_stun > 0:
		$Zip/Line2D.hide();
		zip_timeout -= delta;
		zip_stun -= delta;
	
	pass;


func update_velocity(delta):
	# Get right left input direction
	var input_direction = 0;
	if Input.is_action_pressed("player_right"):
		input_direction += 1;
	if Input.is_action_pressed("player_left"):
		input_direction -= 1;
	
	# Change in velocity since last execution given current inputs
	var delta_velocity = Vector2.ZERO;
	
	# Calculate right/left velocity
	if input_direction == 0: # If no input -> Drag
		delta_velocity += -sign(velocity.x) * Vector2(min(abs(velocity.x), delta*NO_INPUT_DRAG), 0);
	else: # If right/left input -> Accelerate
		delta_velocity += Vector2(delta*ACCELERATION, 0)*input_direction;
		if sign(delta_velocity.x) != sign(velocity.x): # If turning around -
			delta_velocity *= TURN_AROUND_FACTOR;
	
	# Enter fast fall on input
	if Input.is_action_just_pressed("player_fast_fall"):
		fast_falling = true;
	
	# Gravity and jump processing
	# On grounded jump
	if Input.is_action_just_pressed("player_jump") and is_on_floor(): 
		velocity.y = JUMP_SPEED;
	# Reset movement abilites on land
	elif is_on_floor(): 
		double_jump_available = true;
		fast_falling = false;
		zips_since_land = 0;
		if velocity.y != 0:
			velocity.y = 0;
	# On double jump
	elif Input.is_action_just_pressed("player_jump") and double_jump_available: 
		velocity.y = JUMP_SPEED;
		double_jump_available = false;
		fast_falling = false;
	elif fast_falling:
		delta_velocity += Vector2(0, FAST_FALL_GRAVITY_FACTOR*delta*GRAVITY);
	# Reduces the gravity if jump is being held during the first half of the jump
	elif Input.is_action_pressed("player_jump") and velocity.y < 0: 
		delta_velocity += Vector2(0, JUMP_HOLD_GRAVITY_FACTOR*delta*GRAVITY);
	# Apply standard gravity if no input and in air
	else:
		delta_velocity += Vector2(0, delta*GRAVITY);
	
	# If in zip stun -> slow acceleration
	if zip_stun > 0:
		delta_velocity *= ZIP_SLOW_FACTOR;
	
	# Update the velocity
	velocity += delta_velocity;
	
	# Check that the velocity hasn't exceeded MAX_X_SPEED or MAX_Y_SPEED and reset it to the
	# relavent maximum if it has
	if abs(velocity.x) > MAX_X_SPEED:
		velocity.x = MAX_X_SPEED*sign(velocity.x);
	if abs(velocity.y) > MAX_Y_SPEED:
		velocity.y = MAX_Y_SPEED*sign(velocity.y);
	pass;


# -----| On input_direction |-----


func _unhandled_input(event):
	if event is InputEventMouse:
		#print(event, " ", event.global_position, " ", get_angle_to(event.global_position));
		$Attack.look_at(event.global_position);
		$Zip.look_at(event.global_position);
