extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owner.kills_changed.connect(_on_enemy_killed)


func _on_enemy_killed() -> void:
	text = ("Kills: %s" % owner.kills)
