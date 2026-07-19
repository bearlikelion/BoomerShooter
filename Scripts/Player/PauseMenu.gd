class_name PauseMenu

extends CanvasLayer

@onready var player: Player = owner


func _ready() -> void:
	visible = false


# Toggle the pause state with the exit action, ignoring the game over screen's pause
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		if get_tree().paused and visible:
			_resume()
		elif not get_tree().paused:
			_pause()


func _pause() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%ResumeButton.grab_focus()


func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_pressed() -> void:
	_resume()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
