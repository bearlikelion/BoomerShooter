class_name SprintingPlayerState extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var TOP_ANIM_SPEED : float = 1.6
@export var WEAPON_BOB_SPD : float = 8.0
@export var WEAPON_BOB_H : float = 2.5
@export var WEAPON_BOB_V : float = 1.5


func enter(_previous_state: State) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "JumpEnd":
		await ANIMATION.animation_finished
		ANIMATION.play("player_animations/Sprinting",0.5,1.0)
	else:
		ANIMATION.play("player_animations/Sprinting",0.5,1.0)

	# ARMS_VIEW.is_walking = true


func exit() -> void:
	ANIMATION.speed_scale = 1.0
	# ARMS_VIEW.is_walking = false
	# WEAPON.weapon_bob_amount = Vector2(0,0)


func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	# WEAPON.sway_weapon(delta, false)
	# WEAPON._weapon_bob(delta, WEAPON_BOB_SPD, WEAPON_BOB_H, WEAPON_BOB_V)

	set_animation_speed(int(PLAYER.velocity.length()))

	if Input.is_action_just_released("sprint") or PLAYER.velocity.length() == 0:
		transition.emit("IdlePlayerState")

	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 6:
		transition.emit("SlidingPlayerState")

	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")

	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")


func set_animation_speed(spd: int) -> void:
	var alpha: float = remap(spd, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
