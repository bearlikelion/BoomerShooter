extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owner.player_hurt.connect(_on_player_hurt)
	_on_player_hurt()


func _on_player_hurt() -> void:
	text = ("Health: %s" % owner.health)
