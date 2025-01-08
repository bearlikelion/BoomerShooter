class_name Attack extends EnemyState


func _ready() -> void:
	super()
	await owner.ready
	ENEMY.chase_player.connect(_on_chase_player)
	ANIMATION.animation_finished.connect(_on_animation_finished)


func enter(_previous_state: State) -> void:
	ANIMATION.play("Hover_Attack1")


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	ENEMY.velocity = Vector3.ZERO
	ENEMY.velocity = ENEMY.position.direction_to(PLAYER.position) * ENEMY.speed * delta
#
	if !ENEMY.is_on_floor():
		ENEMY.velocity.y -= ENEMY.gravity

	# print("Enemy Velocity: %s" % ENEMY.velocity)

	ENEMY.look_at(PLAYER.position)
	ENEMY.move_and_slide()


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Hover_Attack1":
		ANIMATION.play("Hover_Attack2")
	elif anim_name == "Hover_Attack2":
		ANIMATION.play("Hover_Attack1")


func _on_chase_player() -> void:
	transition.emit("Chase")
