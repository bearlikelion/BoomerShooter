extends Resource
class_name WeaponData

@export var weapon_name: String = ""
@export var max_ammo: int
@export var max_mag: int
@export var fire_rate: int

var ammo: int
var mag: int

signal restored
signal reloaded
signal used
signal empty
signal weapon_ready


func _init() -> void:
	call_deferred("ready")


func ready() -> void:
	reset()
	weapon_ready.emit()


func has_ammo() -> bool:
	return ammo > 0 || mag > 0


func should_reload() -> bool:
	return mag > 0 && ammo == 0


func use() -> void:
	if ammo > 0:
		ammo = max(0, ammo - 1)
		used.emit()
	elif should_reload() or ammo <= 0:
		empty.emit()


func reload() -> void:
	if mag == 0: return
	if ammo == max_ammo: return
	mag = max(0, mag - (max_ammo - ammo))
	ammo = max_ammo
	reloaded.emit()


func restore() -> void:
	# ammo = max_ammo
	mag += max_ammo
	restored.emit()


func reset() -> void:
	ammo = max_ammo
	mag = max_mag * max_ammo
	restored.emit()
