class_name Enemy
extends CharacterBody3D

@export var health: int = 2
@export var speed = 150
@export var skeleton: Skeleton3D
@export var animation_player: AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player = get_tree().get_first_node_in_group("player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# skeleton.physical_bones_start_simulation()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_damage() -> void:
	health -= 1
	print("Took damage! HP: %s" % health)

	if health <= 0:
		skeleton.physical_bones_start_simulation()
		await get_tree().create_timer(1.0).timeout
		queue_free()
