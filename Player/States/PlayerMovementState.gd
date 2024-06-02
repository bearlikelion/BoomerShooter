class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var ARMS_VIEW: SubViewportContainer
var WEAPON: WeaponController
var WEAPON_DATA: WeaponData


func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	WEAPON = PLAYER.WEAPON_CONTROLLER
	WEAPON_DATA = PLAYER.WEAPON_DATA


func _process(_delta: float) -> void:
	pass
