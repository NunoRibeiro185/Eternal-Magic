class_name Targeting extends PlayerState

var ar: AttackResource
var utils = Utils.new()
var previous_state : String
func enter(previous_state_path: String, data := {}) -> void:
	print("TARGETING")
	ar = data["attack"]
	select_indicator()

func update(delta: float) -> void:
	ar.indicator.update(self.owner, owner.get_global_mouse_position(), delta)
	var direction = player.get_movement()
	player.speed = player.RUNNING_SPEED
	player.velocity = direction * player.speed
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

func select_indicator():
	var shape : Polygon2D
	match ar.skillshot_type:
		utils.SkillshotTypes.Circle:
			shape = utils.draw_circle(utils.CIRCLE_POINT_NB, ar.range)
		utils.SkillshotTypes.Triangle:
			shape = utils.draw_triangle(ar.size, ar.range)
		utils.SkillshotTypes.Rectangle:
			shape = utils.draw_rectangle(ar.size, ar.range)
		utils.SkillshotTypes.Cone:
			shape = utils.draw_cone(utils.CIRCLE_POINT_NB/4, ar.size, ar.range)
	ar.indicator.set_reference(owner, shape)
