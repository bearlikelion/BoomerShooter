class_name Enemy
extends CharacterBody3D

signal attack_player
signal chase_player
signal spawn_ammo(ammo_position: Vector3)

@export var health: int = 2
@export var damage: int = 10
@export var speed: int = 150
@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

var dead: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var state_machine: StateMachine = $EnemyStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skeleton.animate_physical_bones = true # HACK FIX NON-ANIMATING BONES


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func headshot() -> void:
	health = 0
	handle_damage()


func take_damage() -> void:
	health -= 1
	handle_damage()


func handle_damage() -> void:
	if health <= 0 and !dead:
		dead = true
		var roll: int = randi_range(1, 100)
		if roll <= 20:
			spawn_ammo.emit(position)

		skeleton.physical_bones_start_simulation()

		# Stop enemy collision
		for bone: Node3D in skeleton.get_children():
			if bone is PhysicalBone3D:
				bone.set_collision_layer_value(2, false)

		player.enemy_killed.emit()
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		attack_player.emit()


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		chase_player.emit()
