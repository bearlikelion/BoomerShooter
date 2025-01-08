class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED: float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var JUMP_VELOCITY : float = 6.5
@export var DOUBLE_JUMP_VELOCITY : float = 4.5
@export_range(0.5,1.0,0.01) var INPUT_MULTIPLIER : float = 0.85
@export var DOUBLE_JUMP : bool = false


func enter(_previous_state: State) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("player_animations/JumpStart")


func exit() -> void:
	DOUBLE_JUMP = false


func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()

	if Input.is_action_just_pressed("jump") and DOUBLE_JUMP == false:
		DOUBLE_JUMP = true
		PLAYER.velocity.y = DOUBLE_JUMP_VELOCITY

	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2.0

	if Input.is_action_pressed("attack"):
		if PLAYER.can_fire():
			WEAPON_DATA.use()

	if Input.is_action_just_pressed("reload"):
		WEAPON_DATA.reload()

	if PLAYER.is_on_floor():
		ANIMATION.play("player_animations/JumpEnd")
		transition.emit("IdlePlayerState")
