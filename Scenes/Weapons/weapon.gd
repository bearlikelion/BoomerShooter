extends Node3D

@export var weapon_data: WeaponData
@export var bullet_scene: PackedScene

var bullet_hole: Resource = preload("res://Scenes/raycast_test.tscn")

@onready var gun_end: Marker3D = %GunEnd
@onready var fps_arms: Node3D = get_tree().get_first_node_in_group("fps_arms")
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	await player.player_ready
	weapon_data.used.connect(_on_weapon_used)
	weapon_data.empty.connect(_on_weapon_empty)
	weapon_data.reloaded.connect(_on_weapon_reloaded)
	# player.WEAPON_DATA = weapon_data


func _on_weapon_used() -> void:
	var shoot_time_diff: int = Time.get_ticks_msec() - player.last_firing_time
	var busy: bool = fps_arms.is_reloading or !(shoot_time_diff > weapon_data.fire_rate)
	if !busy:
		player.last_firing_time = Time.get_ticks_msec()
		fps_arms.fire()
		%ShotSound.pitch_scale = randfn(1.0, 0.1)
		%ShotSound.play()

		var target: Object = player.aimcast.get_collider()
		# print("Target: %s" % target)
		if target is PhysicalBone3D:
			if target.name == "Head":
				target.owner.headshot()

			if target.owner.has_method("take_damage"):
				target.owner.take_damage()

		# Spawn bullet projectiles in the weapon's spread cone
		var aim_direction: Vector3
		if player.aimcast.is_colliding():
			aim_direction = gun_end.global_position.direction_to(player.aimcast.get_collision_point())
		else:
			aim_direction = gun_end.global_transform.basis.z

		for pellet: int in weapon_data.pellet_count:
			_spawn_bullet(_spread_direction(aim_direction))

		# Create Bullet Hole
		if target:
			_bullet_hole(player.aimcast.get_collision_point(), player.aimcast.get_collision_normal())


func _spawn_bullet(direction: Vector3) -> void:
	var bullet: Area3D = bullet_scene.instantiate()
	bullet.transform = gun_end.global_transform
	bullet.scale = Vector3(5, 5, 5)
	bullet.velocity = direction * bullet.muzzle_velocity
	bullet.exploded.connect(_on_bullet_exploded)
	get_tree().root.add_child(bullet)


# Deviate the aim direction by a random angle inside the weapon's spread cone
func _spread_direction(aim_direction: Vector3) -> Vector3:
	if weapon_data.spread_degrees <= 0.0:
		return aim_direction

	var spread: float = deg_to_rad(weapon_data.spread_degrees)
	var right: Vector3 = aim_direction.cross(Vector3.UP)
	if right.length() < 0.001:
		right = Vector3.RIGHT
	right = right.normalized()
	var up: Vector3 = right.cross(aim_direction).normalized()

	return aim_direction.rotated(up, randf_range(-spread, spread)).rotated(right, randf_range(-spread, spread)).normalized()


func get_gun_end_position() -> Vector3:
	var camera: Camera3D = Global.player.CAMERA_CONTROLLER
	var depth: int = Global.player.arms_view.camera.to_local(gun_end.global_position).length()
	var screen_pos: Vector2 = Global.player.arms_view.camera.unproject_position(gun_end.global_position)
	return (camera.project_position(screen_pos, depth))


func _on_bullet_exploded(explosion_position: Vector3) -> void:
	var hole_decal: Decal = bullet_hole.instantiate()
	hole_decal.position = explosion_position
	get_tree().root.add_child(hole_decal)


func _on_weapon_empty() -> void:
	fps_arms.shake()


func _on_weapon_reloaded() -> void:
	%ReloadSound.play()
	fps_arms.reload()


func _bullet_hole(hole_position: Vector3, normal: Vector3) -> void:
	var instance: Decal = bullet_hole.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = hole_position
	if normal != Vector3.UP:
		instance.look_at(instance.global_transform.origin + normal, Vector3.UP)

	if normal != Vector3.UP and normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1, 0, 0), 90)

	await get_tree().create_timer(2.0).timeout

	var face: Tween = get_tree().create_tween()
	face.tween_property(instance, "modulate:a", 0, 1.5)

	await get_tree().create_timer(1.5).timeout
	instance.queue_free()
