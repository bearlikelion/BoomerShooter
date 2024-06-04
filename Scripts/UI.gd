extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%GameOverLayer.visible = false
	owner.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%GameOverLayer.visible = true
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.player.WEAPON_DATA.reset()
	get_tree().reload_current_scene()
