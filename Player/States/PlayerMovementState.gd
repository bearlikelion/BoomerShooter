class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var ARMS_VIEW: SubViewportContainer
var FPS_ARMS: Node3D

# Always read the equipped weapon so states never act on stale data after a swap
var WEAPON_DATA: WeaponData:
	get:
		return PLAYER.WEAPON_DATA if PLAYER != null else null


func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	FPS_ARMS = PLAYER.FPS_ARMS


func _process(_delta: float) -> void:
	pass
