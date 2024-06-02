class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var ARMS_VIEW: SubViewportContainer
var WEAPON: WeaponController


func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	ARMS_VIEW = PLAYER.arms_view
	WEAPON = PLAYER.WEAPON_CONTROLLER


func _process(_delta: float) -> void:
	pass
