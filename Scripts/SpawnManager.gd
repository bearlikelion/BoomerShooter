class_name SpawnManager

extends Node

const PICKUP_POOL_SIZE: int = 4

@export var difficulty: Curve
@export var enemy_scene: PackedScene
@export var ammo_scene: PackedScene
@export var health_scene: PackedScene

var current_wave: int = 0
var is_spawning: bool = false
var ammo_pool: Array[Pickup] = []
var health_pool: Array[Pickup] = []

@onready var spawn_points: Array[Node] = get_children()
@onready var enemies_node: Node = %Enemies


# Pre-instantiate pickup pools so the first loot drop does not stutter
func _ready() -> void:
	ammo_pool = _create_pool(ammo_scene)
	health_pool = _create_pool(health_scene)


func _process(_delta: float) -> void:
	if enemies_node.get_child_count() == 0:
		spawn_wave()


func spawn_wave() -> void:
	current_wave += 1
	var enemies_to_spawn: int = floor(difficulty.sample(current_wave / difficulty.max_value))
	var _spawn_points: Array = []

	for enemy: int in enemies_to_spawn:
		if _spawn_points.size() == 0:
			_spawn_points = spawn_points.duplicate()
			_spawn_points.shuffle()

		var spawn_point: Marker3D = _spawn_points.pop_front()
		var _enemy: Enemy = enemy_scene.instantiate()
		_enemy.position = spawn_point.position
		_enemy.spawn_ammo.connect(_on_ammo_spawned)
		_enemy.spawn_health.connect(_on_health_spawned)
		_enemy.add_to_group("enemy")
		enemies_node.add_child(_enemy)
		await get_tree().create_timer(0.5).timeout


# Build a pool of deactivated pickups kept in the tree for reuse
func _create_pool(scene: PackedScene) -> Array[Pickup]:
	var pool: Array[Pickup] = []
	for i: int in PICKUP_POOL_SIZE:
		pool.append(_add_pooled_pickup(scene))
	return pool


func _add_pooled_pickup(scene: PackedScene) -> Pickup:
	var pickup: Pickup = scene.instantiate()
	pickup.visible = false
	pickup.monitoring = false
	add_child(pickup)
	return pickup


# Reuse a hidden pickup from the pool, growing it if every one is in play
func _take_from_pool(pool: Array[Pickup], scene: PackedScene) -> Pickup:
	for pickup: Pickup in pool:
		if not pickup.visible:
			return pickup

	var extra: Pickup = _add_pooled_pickup(scene)
	pool.append(extra)
	return extra


func _drop_pickup(pool: Array[Pickup], scene: PackedScene, at_position: Vector3) -> void:
	var pickup: Pickup = _take_from_pool(pool, scene)
	pickup.activate(at_position + Vector3.UP * 0.5)


func _on_ammo_spawned(ammo_position: Vector3) -> void:
	_drop_pickup(ammo_pool, ammo_scene, ammo_position)


func _on_health_spawned(health_position: Vector3) -> void:
	_drop_pickup(health_pool, health_scene, health_position)
