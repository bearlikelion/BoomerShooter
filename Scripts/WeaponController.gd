extends Node3D

var weapons: Array[PackedScene] = [
	preload("res://Scenes/Weapons/Handgun/Handgun.tscn"),
	preload("res://Scenes/Weapons/SMG/SMG.tscn"),
	preload("res://Scenes/Weapons/Shotgun/Shotgun.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if weapons.size() > 1:
		if event.is_action_pressed("weapon1"):
			clear_weapon()
			var weapon = weapons[0].instantiate()
			add_child(weapon)
		elif event.is_action_pressed("weapon2"):
			clear_weapon()
			var weapon = weapons[1].instantiate()
			add_child(weapon)
		elif event.is_action_pressed("weapon3"):
			clear_weapon()
			var weapon = weapons[2].instantiate()
			add_child(weapon)


func clear_weapon() -> void:
	get_child(0).queue_free()
