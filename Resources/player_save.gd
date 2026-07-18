class_name PlayerSave
extends Resource

@export var kills: int = 0
@export var runs: int = 0

static func get_save_path() -> String:
	var SAVE_PATH: String = "user://player_save.res"
	return SAVE_PATH


static func load_player_data() -> PlayerSave:
	print("Loaded player data")
	var SAVE_PATH: String = get_save_path()
	if ResourceLoader.exists(SAVE_PATH):
		var player_save: PlayerSave = ResourceLoader.load(SAVE_PATH)
		if player_save is PlayerSave:
			return player_save
	return null


func save_player_data(data: PlayerSave) -> void:
	print("Save player data")
	var SAVE_PATH: String = PlayerSave.get_save_path()
	var result: Error = ResourceSaver.save(data, SAVE_PATH, ResourceSaver.FLAG_COMPRESS)
	assert(result == OK)
