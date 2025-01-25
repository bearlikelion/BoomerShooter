extends Control

@onready var player_save: PlayerSave = PlayerSave.load_player_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%GameOverLayer.visible = false
	owner.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Add Stats to save file
	player_save.runs += 1
	player_save.kills = owner.kills
	player_save.save_player_data(player_save)

	%GameOverLayer.visible = true
	get_tree().paused = true


func _on_restart_pressed() -> void:
	get_tree().paused = false
	Global.player.WEAPON_DATA.reset()
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")


func _on_player_kills_changed() -> void:
	pass # Replace with function body.
