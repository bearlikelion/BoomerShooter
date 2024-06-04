extends Area3D

signal exploded

@export var muzzle_velocity = 100
@export var g = Vector3.DOWN * 0

var velocity: Vector3 = Vector3.ZERO
var end_position: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	velocity += g * delta
	# look_at(transform.origin + velocity.normalized(), Vector3.UP)
	look_at(end_position)
	transform.origin += velocity * delta


func _on_body_entered(_body: Node3D) -> void:
	emit_signal("exploded", transform.origin)
	# queue_free()


func _on_area_entered(_area: Area3D) -> void:
	pass
	# print("Bullet area entered: %s" % area.name)
