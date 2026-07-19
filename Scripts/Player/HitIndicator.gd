class_name HitIndicator

extends Control

@export var DISTANCE: float = 140.0
@export var FADE_TIME: float = 1.2
@export var INDICATOR_COLOR: Color = Color(1.0, 0.1, 0.1, 0.9)

var _fade_tween: Tween

@onready var player: Player = owner


# Start hidden and listen for the player getting hurt
func _ready() -> void:
	modulate.a = 0.0
	player.player_hurt.connect(_on_player_hurt)


# Point at the attacker and fade out, but only for hits from outside the camera view
func _on_player_hurt(hit_position: Vector3) -> void:
	var camera: Camera3D = player.CAMERA_CONTROLLER
	if camera.is_position_in_frustum(hit_position):
		return

	var to_hit: Vector3 = hit_position - camera.global_position
	var hit_flat: Vector2 = Vector2(to_hit.x, to_hit.z)
	var forward: Vector3 = -camera.global_transform.basis.z
	var forward_flat: Vector2 = Vector2(forward.x, forward.z)
	rotation = forward_flat.angle_to(hit_flat)

	if _fade_tween != null:
		_fade_tween.kill()
	modulate.a = 1.0
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)


# Draw a wedge offset from screen center pointing outward toward the attacker
func _draw() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-40.0, -DISTANCE),
		Vector2(40.0, -DISTANCE),
		Vector2(0.0, -DISTANCE - 35.0)
	])
	draw_colored_polygon(points, INDICATOR_COLOR)
