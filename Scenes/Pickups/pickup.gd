class_name Pickup

extends Area3D


# Move to a position and enable interaction; a hidden pickup is free for reuse
func activate(at_position: Vector3) -> void:
	global_position = at_position
	visible = true
	set_deferred("monitoring", true)


# Hide and disable until the pool reuses it
func deactivate() -> void:
	visible = false
	set_deferred("monitoring", false)


# Override in each pickup type; return true when the pickup was consumed
func _apply(_player: Player) -> bool:
	return false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		if _apply(player):
			deactivate()
