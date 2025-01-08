extends HBoxContainer

var weapon_data: WeaponData

@onready var weapon: Node3D = get_tree().get_first_node_in_group("weapon")
# @onready var bullet_icon_scene = preload("./bullet_icon.tscn")
@onready var ammo: Label = %Ammo
@onready var mag_count: Label = %Magezine


func _ready() -> void:
	# await weapon_data.weapon_ready
	await owner.ready
	weapon_data = owner.WEAPON_DATA
	ammo.text = str(weapon_data.ammo)
	mag_count.text = "%s" % str(weapon_data.mag)
	weapon_data.connect("used", on_ammo_used)
	weapon_data.connect("reloaded", on_ammo_reloaded)
	weapon_data.connect("restored", on_ammo_reloaded)


func on_ammo_used() -> void:
	ammo.text = str(weapon_data.ammo)


func on_ammo_reloaded() -> void:
	ammo.text = str(weapon_data.ammo)
	mag_count.text = "%s" % str(weapon_data.mag)
