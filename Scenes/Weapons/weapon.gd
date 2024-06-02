extends Node3D

@export var weapon_data: WeaponData
@export var bullet_scene: PackedScene

@onready var gun_end: Marker3D = %GunEnd

func _ready() -> void:
	weapon_data.used.connect(_on_weapon_used)
	if Global.player:
		Global.player.WEAPON_DATA = weapon_data


func _on_weapon_used() -> void:
	var bullet: Area3D = bullet_scene.instantiate()
	print("Gun End Pos: %s" % gun_end.global_position)
	bullet.transform = gun_end.global_transform
	bullet.velocity = bullet.transform.basis.z * bullet.muzzle_velocity
	print("Bullet Pos: %s" % bullet.position)
	get_tree().root.add_child(bullet)


func get_gun_end_position() -> Vector3:
	var camera = Global.player.CAMERA_CONTROLLER
	var depth = Global.player.arms_view.camera.to_local(gun_end.global_position).length()
	var screen_pos = Global.player.arms_view.camera.unproject_position(gun_end.global_position)
	return (camera.project_position(screen_pos, depth))
