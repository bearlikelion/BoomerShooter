extends Node3D

@export var recoil_amount : Vector3
@export var snap_amount : float
@export var speed : float

var current_rotation : Vector3
var target_rotation : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	if owner.WEAPON_DATA:
		owner.WEAPON_DATA.used.connect(add_recoil)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)


func add_recoil() -> void:
	target_rotation += Vector3(recoil_amount.x, randf_range(-recoil_amount.y, recoil_amount.y), randf_range(-recoil_amount.z, recoil_amount.z))
