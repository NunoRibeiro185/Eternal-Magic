class_name Targeting extends PlayerState

var ar: AttackResource
var utils = Utils.new()
var previous_state : String

var shape : Polygon2D
var collision_shape = null

func enter(_previous_state_path: String, data := {}) -> void:
	print("TARGETING")
	ar = data["attack"]
	var shape_and_collision = utils.select_shape(ar.shape, ar.width, ar.attack_range)
	shape = shape_and_collision[0]
	collision_shape = shape_and_collision[1]
	ar.indicator.set_reference(owner, shape)

func update(delta: float) -> void:
	ar.indicator.update(self.owner, owner.get_global_mouse_position(), delta)
	player.direction = player.get_movement()
	player.speed = player.RUNNING_SPEED
	player.velocity = player.direction * player.speed
	player.get_movement()
	player.move_and_slide()
	

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack1") and ar.indicator.activated:
		ar.indicator.reset()
		finished.emit(CASTING, {"attack" : ar})
	if Input.is_action_just_pressed("attack2"):
		reset()
		

func reset():
	ar.indicator.reset()
	finished.emit(IDLE)
