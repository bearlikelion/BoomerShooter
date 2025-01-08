class_name Player

extends CharacterBody3D

signal shoot(origin: Vector3, normal: Vector3, gun_end_position: Vector3)
signal weapon_changed(weapon_data: WeaponData)
signal player_ready
signal player_hurt
signal player_died
signal enemy_killed
signal kills_changed

@export var FPS_ARMS: Node3D
@export var MOUSE_SENSITIVITY: float = 0.33
@export var TILT_LOWER_LIMIT: float = deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT: float = deg_to_rad(90.0)
@export var ANIMATIONPLAYER: AnimationPlayer
@export var CAMERA_CONTROLLER: Camera3D
@export var ROLL_ANGLE: float = 0.65
@export var ROLL_SPEED: int = 300
@export var WEAPON_DATA: WeaponData = null

var health: int = 100
var kills: int = 0

var last_firing_time: int = 0

var _mouse_input: bool = false
var _camera_rotation: Vector3
var _player_rotation: Vector3
var _mouse_rotation: Vector3

var _current_rotation: float
var _rotation_input: float
var _tilt_input: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity: float = 12.0

var been_hurt: bool = false
var hurt_timer: Timer = Timer.new()

@onready var aimcast: RayCast3D = %AimCast


func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	enemy_killed.connect(_on_enemy_killed)

	# Hurt Timer
	hurt_timer.wait_time = 1.0
	hurt_timer.autostart = true
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	hurt_timer.name = "HurtTimer"
	add_child(hurt_timer)

	player_ready.emit()

func _physics_process(delta: float) -> void:
	update_camera(delta)
	CAMERA_CONTROLLER.rotation.z = _calc_roll(ROLL_ANGLE, ROLL_SPEED) * 2


func _input(event: InputEvent) -> void:
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
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
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

	var side: float = velocity.dot(CAMERA_CONTROLLER.transform.basis.x)
	# print("Side: %s" % side)
	var roll_sign: float = 1.0 if side < 0.0 else -1.0
	side = absf(side)

	var value: float = rollangle
	if (side < rollspeed):
		side = side * value / rollspeed
	else:
		side = value

	return side * roll_sign


func set_weapon(weapon_data: WeaponData) -> void:
	# print("Weapon changed! %s" % str(weapon_data))
	WEAPON_DATA = weapon_data
	weapon_changed.emit()


func can_fire() -> bool:
	if FPS_ARMS.is_reloading:
		return false

	var shoot_time_diff: int = Time.get_ticks_msec() - last_firing_time
	if shoot_time_diff < WEAPON_DATA.fire_rate:
		return false

	return true


func take_damage(damage: int) -> void:
	if !been_hurt:
		been_hurt = true
		health -= damage

		if !%OuchSound.playing:
			%OuchSound.play()

		if health <= 0:
			player_died.emit()
		else:
			player_hurt.emit()


func _on_hurt_box_body_entered(body: Node3D) -> void:
	if body.owner.is_in_group("enemy"):
		take_damage(body.owner.damage)
		#print("Body name: %s" % body.name)
		#print("Body is enemy, player should take damage")


func _on_hurt_timer_timeout() -> void:
	if been_hurt:
		been_hurt = false


func _on_enemy_killed() -> void:
	kills += 1
	kills_changed.emit()
