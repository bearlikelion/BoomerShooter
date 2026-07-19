class_name AmmoPickup

extends Pickup


# Refill reserve ammo for every carried weapon, not just the equipped one
func _apply(_player: Player) -> bool:
	var manager: WeaponManager = get_tree().get_first_node_in_group("weapon_manager")
	if manager == null:
		return false

	for weapon: Node3D in manager.weapons:
		weapon.weapon_data.restore()

	return true
