class_name LowHealthOverlay

extends TextureRect

@export var LOW_HEALTH_THRESHOLD: int = 30
@export var MAX_ALPHA: float = 0.5
@export var PULSE_SPEED: float = 5.0

var _time: float = 0.0

@onready var player: Player = owner


# Pulse a red vignette while the player is at low health
func _process(delta: float) -> void:
	if player.health <= LOW_HEALTH_THRESHOLD and player.health > 0:
		_time += delta
		modulate.a = MAX_ALPHA * (0.7 + 0.3 * sin(_time * PULSE_SPEED))
	else:
		modulate.a = 0.0
		_time = 0.0
