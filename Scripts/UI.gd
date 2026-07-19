class_name PlayerUI

extends Control

var run_time: float = 0.0

@onready var player_save: PlayerSave = PlayerSave.load_player_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%GameOverLayer.visible = false
	owner.player_died.connect(_on_player_died)


# Track how long this run has lasted; stops automatically while paused
func _process(delta: float) -> void:
	run_time += delta


func _on_player_died() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Add Stats to save file
	player_save.runs += 1
	player_save.kills = owner.kills
	player_save.add_run(run_time, owner.kills)
	player_save.save_player_data(player_save)

	%GameOverLayer.visible = true
	get_tree().paused = true

	# Focus the restart button so the game over menu is controller navigable
	%Restart.grab_focus()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")


func _on_player_kills_changed() -> void:
	pass # Replace with function body.
