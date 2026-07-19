class_name WeaponManager

extends Node3D

signal weapon_equipped(index: int)

var weapons: Array[Node3D] = []
var current_index: int = 0

@onready var player: Player = get_tree().get_first_node_in_group("player")


# Collect child weapon scenes and equip the first one once the player is ready
func _ready() -> void:
	add_to_group("weapon_manager")
	for child: Node in get_children():
		if child is Node3D:
			weapons.append(child)

	await player.player_ready
	equip(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon1"):
		equip(0)
	elif event.is_action_pressed("weapon2"):
		equip(1)
	elif event.is_action_pressed("weapon3"):
		equip(2)


# Show only the selected weapon and hand its data to the player
func equip(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return

	current_index = index
	for i: int in weapons.size():
		weapons[i].visible = i == index

	player.set_weapon(weapons[index].weapon_data)
	weapon_equipped.emit(index)
