extends Node3D

@export var animation_player: AnimationPlayer

var is_reloading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.animation_finished.connect(func(animation_name: StringName) -> void:
		if animation_name == "ReloadMag":
			is_reloading = false
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func ground_impact() -> void:
	animation_player.play("GroundImpact")


func fire() -> void:
	animation_player.play("Fire")


func shake() -> void:
	animation_player.play("Shake")


func reload() -> void:
	is_reloading = true
	animation_player.play("ReloadMag")


func walk() -> void:
	animation_player.play("Walk")


func idle() -> void:
	animation_player.play("Idle")
