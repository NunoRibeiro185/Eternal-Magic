extends PlayerState

var ar: AttackResource
var timer : Timer

func enter(previous_state_path: String, data := {}) -> void:
	print("CASTING")
	ar = data["attack"]
	if ar.cast_time  == 0:
		finished.emit(IDLE)
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", cast_over)
	timer.start(ar.cast_time)

func physics_update(delta: float) -> void:
	print("time left: ", timer.time_left)
	if ar.can_move_while_casting:
		var direction = player.get_movement()
		player.speed = player.RUNNING_SPEED
		player.velocity = direction * player.speed
		player.move_and_slide()

func cast_over():
	#Execute attack
	finished.emit(IDLE)
	timer.queue_free()
