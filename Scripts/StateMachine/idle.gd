class_name Idle extends PlayerState

func enter(_previous_state_path: String, _data := {}) -> void:
	player.velocity = Vector2(0.0, 0.0)
	print("IDLE")
	#player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	player.direction = player.get_movement()
	if player.direction: 
		finished.emit(RUNNING)
	else:
		player.get_move() 
	player.move_and_slide()
