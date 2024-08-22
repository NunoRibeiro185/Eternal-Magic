class_name Idle extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity = Vector2(0.0, 0.0)
	print("IDLE")
	#player.animation_player.play("idle")

func physics_update(_delta: float) -> void:
	var direction = player.get_movement()
	if direction: 
		finished.emit(RUNNING)
	else:
		player.get_move() 
	player.move_and_slide()
