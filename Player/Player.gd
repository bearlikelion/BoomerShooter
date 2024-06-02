class_name Player

extends CharacterBody3D

@export var MOUSE_SENSITIVITY: float = 0.33
@export var TILT_LOWER_LIMIT: float = deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT: float = deg_to_rad(90.0)
@export var ANIMATIONPLAYER: AnimationPlayer
@export var CAMERA_CONTROLLER: Camera3D
@export var WEAPON_CONTROLLER: WeaponController
@export var ROLL_ANGLE: float = 0.65
@export var ROLL_SPEED: int = 300


var last_firing_time: int = 0

var _mouse_input : bool = false

var _camera_rotation: Vector3
var _player_rotation: Vector3
var _mouse_rotation: Vector3

var _current_rotation: float
var _rotation_input: float
var _tilt_input: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity: float = 12.0

@onready var arms_view = %ArmsView
@onready var weapon_data = preload("res://Resources/blaster_pistol.tres")

func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	arms_view.copy_pos_rot(CAMERA_CONTROLLER.global_position, CAMERA_CONTROLLER.rotation)
	ANIMATIONPLAYER.play("player_animations/RESET")


func _physics_process(delta: float) -> void:
	# Global.debug.add_property("Velocity","%.2f" % velocity.length(), 2)
	update_camera(delta)
	CAMERA_CONTROLLER.rotation.z = _calc_roll(ROLL_ANGLE, ROLL_SPEED) * 2


func _input(event):
	if event.is_action_pressed("exit"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()

	if event.is_action_pressed("attack"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY


func update_camera(delta: float) -> void:
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0


func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x,direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z,direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)


func update_gravity(delta: float) -> void:
	velocity.y -= gravity * delta


func update_velocity() -> void:
	move_and_slide()


# Returns a value for how much the Camera Mount should tilt to the side.
# TODO Fix rotation side
func _calc_roll(rollangle: float, rollspeed: float) -> float:
	if rollangle == 0.0 or rollspeed == 0:
		return 0

	var side = velocity.dot(CAMERA_CONTROLLER.transform.basis.x)
	# print("Side: %s" % side)
	var roll_sign = 1.0 if side < 0.0 else -1.0
	side = absf(side)

	var value = rollangle
	if (side < rollspeed):
		side = side * value / rollspeed
	else:
		side = value

	return side * roll_sign
