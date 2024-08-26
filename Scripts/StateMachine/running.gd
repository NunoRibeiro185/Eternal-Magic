extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	#player.animation_player.play("run")
	print("RUNNING")
	pass
	
func physics_update(_delta: float) -> void:
	player.direction = player.get_movement()
	player.speed = player.RUNNING_SPEED
	player.velocity = player.direction * player.speed
	player.move_and_slide()
	player.get_move()
	
	if is_equal_approx(player.direction.x, 0.0) and is_equal_approx(player.direction.y, 0.0):
		finished.emit(IDLE)
