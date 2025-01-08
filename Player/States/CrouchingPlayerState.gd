class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED: float = 2.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0
@export var WEAPON_BOB_SPD : float = 2.0
@export var WEAPON_BOB_H : float = 1.5
@export var WEAPON_BOB_V : float = 0.7

@onready var CROUCH_SHAPECAST : ShapeCast3D = %ShapeCast3D

var RELEASED : bool = false


func enter(previous_state: State) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("player_animations/Crouching", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "player_animations/Crouching"
		ANIMATION.seek(1.0, true)


func exit() -> void:
	RELEASED = false

	# WEAPON.weapon_bob_amount = Vector2(0,0)


func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()

	# WEAPON.sway_weapon(delta, false)
	# WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)

	if Input.is_action_just_released("crouch"):
		uncrouch()
	elif Input.is_action_pressed("crouch") == false and RELEASED == false:
		RELEASED = true
		uncrouch()

	if Input.is_action_pressed("attack"):
		if PLAYER.can_fire():
			WEAPON_DATA.use()

	if Input.is_action_just_pressed("reload"):
		WEAPON_DATA.reload()


func uncrouch() -> void:
	if CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATION.play("player_animations/Crouching", -1.0 ,-CROUCH_SPEED, true)
		await ANIMATION.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
