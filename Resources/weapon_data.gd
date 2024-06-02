extends Resource
class_name WeaponData

@export var weapon_name: String = ""
@export var max_ammo: int
@export var max_mag: int
@export var fire_rate: int

var ammo : int
var mag : int

signal restored
signal reloaded
signal used
signal empty


func _init() -> void:
	call_deferred("ready")


func ready() -> void:
	ammo = max_ammo
	mag = max_mag


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
	ammo = max_ammo
	mag = max(0, mag - 1)
	reloaded.emit()


func restore() -> void:
	ammo = max_ammo
	mag = max_mag
	restored.emit()
