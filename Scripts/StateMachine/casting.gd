extends PlayerState

var ar: AttackResource
var timer: Timer
var spell_manager: SpellManager
var direction: Vector2
var cast_bar : TextureProgressBar
const CAST_BAR = preload("res://Scenes/UI/cast_bar.tscn")

func enter(_previous_state_path: String, data := {}) -> void:
	print("CASTING")
	ar = data["attack"]
	spell_manager = data["spell_manager"]
	direction = player.global_position.direction_to(player.get_global_mouse_position())
	if ar.cast_time  == 0:
		finished.emit(IDLE)
	timer = Timer.new()
	cast_bar = CAST_BAR.instantiate()
	cast_bar.max_value = ar.cast_time
	player.cast_bar.add_child(cast_bar)
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
		
func update(delta: float) -> void:
	cast_bar.value = timer.time_left
	print("Cast: ", cast_bar.value)
	
func cast_over():
	#Execute attack
	spell_manager.activate(direction)
	finished.emit(IDLE)
	if timer:
		timer.queue_free()
	if cast_bar:
		cast_bar.queue_free()
