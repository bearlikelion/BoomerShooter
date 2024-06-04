extends Node3D

@export var weapon_data: WeaponData
@export var bullet_scene: PackedScene

var bullet_hole = preload("res://Scenes/raycast_test.tscn")

@onready var gun_end: Marker3D = %GunEnd
@onready var fps_arms: Node3D = get_tree().get_first_node_in_group("fps_arms")
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	await player.player_ready
	weapon_data.used.connect(_on_weapon_used)
	weapon_data.empty.connect(_on_weapon_empty)
	weapon_data.reloaded.connect(_on_weapon_reloaded)
	player.set_weapon(weapon_data)
	# player.WEAPON_DATA = weapon_data


func _on_weapon_used() -> void:
	var shoot_time_diff = Time.get_ticks_msec() - player.last_firing_time
	var busy = fps_arms.is_reloading or !(shoot_time_diff > weapon_data.fire_rate)
	if !busy:
		player.last_firing_time = Time.get_ticks_msec()
		fps_arms.fire()
		%ShotSound.pitch_scale = randfn(1.0, 0.1)
		%ShotSound.play()

		var target: Object = player.aimcast.get_collider()
		# print("Target: %s" % target)
		if target is PhysicalBone3D:
			if target.name == "Head":
				target.owner.take_damage()
				target.owner.take_damage()

			if target.owner.has_method("take_damage"):
				target.owner.take_damage()

		# Spawn Bullet Projectile
		var bullet: Area3D = bullet_scene.instantiate()
		bullet.transform = gun_end.global_transform
		bullet.scale = Vector3(5, 5, 5)
		bullet.velocity = bullet.transform.basis.z * bullet.muzzle_velocity
		if target:
			bullet.end_position = target.position # result.get("position")
		bullet.exploded.connect(_on_bullet_exploded)
		get_tree().root.add_child(bullet)

		# Create Bullet Hole
		if target:
			_bullet_hole(player.aimcast.get_collision_point(), player.aimcast.get_collision_normal())


func get_gun_end_position() -> Vector3:
	var camera = Global.player.CAMERA_CONTROLLER
	var depth = Global.player.arms_view.camera.to_local(gun_end.global_position).length()
	var screen_pos = Global.player.arms_view.camera.unproject_position(gun_end.global_position)
	return (camera.project_position(screen_pos, depth))


func _on_bullet_exploded(explosion_position: Vector3) -> void:
	var hole_decal = bullet_hole.instantiate()
	hole_decal.position = explosion_position
	get_tree().root.add_child(hole_decal)


func _on_weapon_empty() -> void:
	fps_arms.shake()


func _on_weapon_reloaded() -> void:
	%ReloadSound.play()
	fps_arms.reload()


func _bullet_hole(hole_position: Vector3, normal: Vector3) -> void:
	var instance = bullet_hole.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = hole_position
	if normal != Vector3.UP:
		instance.look_at(instance.global_transform.origin + normal, Vector3.UP)

	if normal != Vector3.UP and normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1, 0, 0), 90)

	await get_tree().create_timer(2.0).timeout

	var face = get_tree().create_tween()
	face.tween_property(instance, "modulate:a", 0, 1.5)

	await get_tree().create_timer(1.5).timeout
	instance.queue_free()
