class_name HealthLabel

extends Label

@export var HIGH_COLOR: Color = Color(0.4, 1.0, 0.4)
@export var MID_COLOR: Color = Color(1.0, 0.85, 0.25)
@export var LOW_COLOR: Color = Color(1.0, 0.25, 0.25)

@onready var player: Player = owner


# Show the starting health and update whenever the player is hurt
func _ready() -> void:
	player.player_hurt.connect(_on_player_hurt)
	player.health_changed.connect(_refresh)
	_refresh()


func _on_player_hurt(_hit_position: Vector3) -> void:
	_refresh()


# Color the label green, orange, or red based on remaining health
func _refresh() -> void:
	text = "HP %s" % str(player.health)
	if player.health > 60:
		modulate = HIGH_COLOR
	elif player.health > 30:
		modulate = MID_COLOR
	else:
		modulate = LOW_COLOR
