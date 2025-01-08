extends Node

@export var difficulty: Curve
@export var enemy_scene: PackedScene
@export var ammo_scene: PackedScene

var current_wave: int = 0
var is_spawning: bool = false

@onready var spawn_points: Array[Node] = get_children()
@onready var enemies_node: Node = %Enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		_enemy.add_to_group("enemy")
		enemies_node.add_child(_enemy)
		await get_tree().create_timer(0.5).timeout


func _on_ammo_spawned(ammo_position: Vector3) -> void:
	var ammo_pickup: Area3D = ammo_scene.instantiate()
	ammo_pickup.position = ammo_position
	ammo_pickup.position.y += 0.5
	get_tree().root.add_child(ammo_pickup)
