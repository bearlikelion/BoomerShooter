class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION: AnimationPlayer
var ARMS_VIEW: SubViewportContainer
var FPS_ARMS: Node3D
var WEAPON_DATA: WeaponData


func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	FPS_ARMS = PLAYER.FPS_ARMS
	WEAPON_DATA = PLAYER.WEAPON_DATA


func _process(_delta: float) -> void:
	pass
