extends PlayerState

var ar: AttackResource
var timer: Timer
var spell_manager: SpellManager

func enter(_previous_state_path: String, data := {}) -> void:
	print("CASTING")
	ar = data["attack"]
	spell_manager = data["spell_manager"]
	if ar.cast_time  == 0:
		finished.emit(IDLE)
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", cast_over)
	timer.start(ar.cast_time)

func physics_update(delta: float) -> void:
	print("time left: ", timer.time_left)
	if ar.can_move_while_casting:
		player.direction = player.get_movement()
		player.speed = player.RUNNING_SPEED
		player.velocity = player.direction * player.speed
		player.move_and_slide()

func cast_over():
	#Execute attack
	spell_manager.activate()
	finished.emit(IDLE)
	timer.queue_free()
