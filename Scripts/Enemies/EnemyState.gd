class_name EnemyState
extends State


var ENEMY: Enemy
var PLAYER: Player
var ANIMATION: AnimationPlayer


func _ready() -> void:
	await owner.ready
	ENEMY = owner as Enemy
	PLAYER = ENEMY.player
	ANIMATION = ENEMY.animation_player
