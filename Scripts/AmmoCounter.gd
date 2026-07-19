class_name AmmoCounter

extends Label3D

@export var NORMAL_COLOR: Color = Color.WHITE
@export var RELOAD_COLOR: Color = Color.RED

var weapon_data: WeaponData

@onready var player: Player = owner


# Follow the owning player's weapon and show its ammo beside the gun
func _ready() -> void:
	await player.ready
	player.weapon_changed.connect(_on_weapon_changed)
	_track_weapon(player.WEAPON_DATA)


# Swap signal connections over to the newly equipped weapon
func _track_weapon(new_weapon_data: WeaponData) -> void:
	if weapon_data != null:
		weapon_data.used.disconnect(_refresh)
		weapon_data.reloaded.disconnect(_refresh)
		weapon_data.restored.disconnect(_refresh)

	weapon_data = new_weapon_data
	if weapon_data == null:
		text = ""
		return

	weapon_data.used.connect(_refresh)
	weapon_data.reloaded.connect(_refresh)
	weapon_data.restored.connect(_refresh)
	_refresh()


# Update the readout and turn red when the magazine is empty
func _refresh() -> void:
	text = "%s / %s" % [str(weapon_data.ammo), str(weapon_data.mag)]
	if weapon_data.ammo == 0:
		modulate = RELOAD_COLOR
	else:
		modulate = NORMAL_COLOR


func _on_weapon_changed() -> void:
	_track_weapon(player.WEAPON_DATA)
