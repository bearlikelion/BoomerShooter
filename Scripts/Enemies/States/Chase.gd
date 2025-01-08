class_name Chase extends EnemyState


func _ready() -> void:
	super()
	await owner.ready
	ENEMY.attack_player.connect(_on_attack_player)
	ANIMATION.animation_finished.connect(_on_animation_finished)


func enter(_previous_state: State) -> void:
	ANIMATION.play("Run1")


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
	if anim_name == "Run1":
		ANIMATION.play("Run2")
	elif anim_name == "Run2":
		ANIMATION.play("Run1")


func _on_attack_player() -> void:
	transition.emit("Attack")
