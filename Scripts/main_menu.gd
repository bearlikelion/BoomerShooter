class_name MainMenu

extends Control

@onready var player_save: PlayerSave = PlayerSave.load_player_data()
@onready var kills_value: Label = %KillsValue
@onready var runs_value: Label = %RunsValue
@onready var run_history: VBoxContainer = %RunHistory
@onready var play_button: Button = %PlayButton


# Load or create the save file, fill in stats, and focus play for controller navigation
func _ready() -> void:
	if player_save == null:
		print("Create new save file")
		var _new_save_file: PlayerSave = PlayerSave.new()
		_new_save_file.save_player_data(_new_save_file)
		player_save = _new_save_file
	else:
		print("Loaded player save")
		kills_value.text = str(player_save.kills)
		runs_value.text = str(player_save.runs)

	_populate_run_history()
	play_button.grab_focus()


# List the most recent runs as time and kill rows
func _populate_run_history() -> void:
	if player_save.run_history.is_empty():
		run_history.add_child(_make_history_row("No runs yet"))
		return

	for run: Dictionary in player_save.run_history:
		run_history.add_child(_make_history_row("%s  -  %s kills" % [_format_time(run.time), str(run.kills)]))


func _make_history_row(row_text: String) -> Label:
	var row: Label = Label.new()
	row.text = row_text
	row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_theme_font_size_override("font_size", 24)
	return row


static func _format_time(seconds: float) -> String:
	var mins: int = floori(seconds / 60.0)
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/TestLevel.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
