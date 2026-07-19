class_name KillsLabel

extends Label

@onready var player: Player = owner


func _ready() -> void:
	player.kills_changed.connect(_on_kills_changed)


# Update the counter and pop the label so new kills are hard to miss
func _on_kills_changed() -> void:
	text = "KILLS: %s" % str(player.kills)
	pivot_offset = Vector2(size.x, 0.0)
	scale = Vector2(1.4, 1.4)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
