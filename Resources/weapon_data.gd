extends Resource
class_name WeaponData

@export var weapon_name = ""
@export var max_ammo : int
@export var max_mag : int
var ammo : int
var mag : int

signal restored
signal reloaded
signal used


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
	ammo = max(0, ammo - 1)
	used.emit()


func reload() -> void:
	if mag == 0: return
	ammo = max_ammo
	mag = max(0, mag - 1)
	reloaded.emit()


func restore() -> void:
	ammo = max_ammo
	mag = max_mag
	restored.emit()
