class_name Enemy
extends CharacterBody3D

signal attack_player
signal chase_player
signal spawn_ammo(ammo_position: Vector3)

@export var health: int = 2
@export var speed = 150
@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var state_machine = $EnemyStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skeleton.animate_physical_bones = true # HACK FIX NON-ANIMATING BONES


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_damage() -> void:
	health -= 1
	# print("Took damage! HP: %s" % health)

	if health <= 0:
		var roll = randi_range(1, 100)
		if roll <= 15:
			spawn_ammo.emit(position)

		skeleton.physical_bones_start_simulation()
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		attack_player.emit()


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		chase_player.emit()
