class_name HealthPickup

extends Pickup

@export var HEAL_AMOUNT: int = 25


# Heal the player unless they are already at full health
func _apply(player: Player) -> bool:
	if player.health >= Player.MAX_HEALTH:
		return false

	player.heal(HEAL_AMOUNT)
	return true
