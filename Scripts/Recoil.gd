class_name Recoil

extends Node3D

@export var snap_amount: float
@export var speed: float

var current_rotation: Vector3
var target_rotation: Vector3

@onready var player: Player = owner


# Follow the equipped weapon so each weapon applies its own recoil
func _ready() -> void:
	await player.ready
	player.weapon_changed.connect(_on_weapon_changed)
	_connect_weapon()


func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)


func _connect_weapon() -> void:
	if player.WEAPON_DATA and not player.WEAPON_DATA.used.is_connected(add_recoil):
		player.WEAPON_DATA.used.connect(add_recoil)


func _on_weapon_changed() -> void:
	_connect_weapon()


func add_recoil() -> void:
	var recoil: Vector3 = player.WEAPON_DATA.recoil
	target_rotation += Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z))
