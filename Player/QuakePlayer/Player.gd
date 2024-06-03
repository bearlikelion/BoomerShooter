extends CharacterBody3D

# Movement
@export var MAX_VELOCITY_AIR = 0.6
@export var MAX_VELOCITY_GROUND = 6.0
@export var MAX_ACCELERATION = 10 * MAX_VELOCITY_GROUND
@export var GRAVITY = 15.34
@export var STOP_SPEED = 1.5
@export var JUMP_IMPULSE = sqrt(2 * GRAVITY * 0.85)
@export var PLAYER_WALKING_MULTIPLIER = 0.666
@export var PLAYER_SPRINTING_MULTIPLIER = 1.666

var direction = Vector3()
var friction = 4
var wish_jump
var walking = false
var sprinting = false

# Camera
var sensitivity = 0.05

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse lock
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("attack"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(event)

func _handle_camera_rotation(event: InputEvent):
	# Rotate the camera based on the mouse movement
	rotate_y(deg_to_rad(-event.relative.x * sensitivity))
	$Head.rotate_x(deg_to_rad(-event.relative.y * sensitivity))

	# Stop the head from rotating to far up or down
	$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-60), deg_to_rad(90))

func _physics_process(delta):
	process_input()
	process_movement(delta)

func process_input():
	direction = Vector3()

	# Movement directions
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	# Jumping
	wish_jump = Input.is_action_pressed("jump")

	# Walking
	# walking = Input.is_action_pressed("walk")

	# Sprinting
	# sprinting = Input.is_action_pressed("sprint")

func process_movement(delta):
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir = direction.normalized()

	if is_on_floor():
		# If wish_jump is true then we won't apply any friction and allow the
		# player to jump instantly, this gives us a single frame where we can
		# perfectly bunny hop
		if wish_jump:
			velocity.y = JUMP_IMPULSE
			# Update velocity as if we are in the air
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		else:
			if walking:
				velocity.x *= PLAYER_WALKING_MULTIPLIER
				velocity.z *= PLAYER_WALKING_MULTIPLIER

			if sprinting:
				velocity.x *= PLAYER_SPRINTING_MULTIPLIER
				velocity.z *= PLAYER_SPRINTING_MULTIPLIER

			velocity = update_velocity_ground(wish_dir, delta)
	else:
		# Only apply gravity while in the air
		velocity.y -= GRAVITY * delta
		velocity = update_velocity_air(wish_dir, delta)

	# Move the player once velocity has been calculated
	move_and_slide()

func accelerate(wish_dir: Vector3, max_speed: float, delta):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_speed - current_speed, 0, MAX_ACCELERATION * delta)

	return velocity + add_speed * wish_dir

func update_velocity_ground(wish_dir: Vector3, delta):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length()

	if speed != 0:
		var control = max(STOP_SPEED, speed)
		var drop = control * friction * delta

		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed

	return accelerate(wish_dir, MAX_VELOCITY_GROUND, delta)

func update_velocity_air(wish_dir: Vector3, delta):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR, delta)
