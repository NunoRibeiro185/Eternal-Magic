extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	#player.animation_player.play("run")
	print("RUNNING")
	pass
	
func physics_update(delta: float) -> void:
	var direction = player.get_movement()
	player.speed = player.RUNNING_SPEED
	player.velocity = direction * player.speed
	player.move_and_slide()
	player.get_move()
	
	if is_equal_approx(direction.x, 0.0) and is_equal_approx(direction.y, 0.0):
		finished.emit(IDLE)
