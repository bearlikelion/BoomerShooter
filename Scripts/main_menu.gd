extends Control

@onready var player_save = PlayerSave.load_player_data()
@onready var kills_value: Label = %KillsValue
@onready var runs_value: Label = %RunsValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_save == null:
		print("Create new save file")
		var _new_save_file: PlayerSave = PlayerSave.new()
		_new_save_file.save_player_data(_new_save_file)
	else:
		print("Loaded player save")
		kills_value.text = str(player_save.kills)
		runs_value.text = str(player_save.runs)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/TestLevel.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
