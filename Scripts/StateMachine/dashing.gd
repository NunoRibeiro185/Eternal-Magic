class_name Dashing extends PlayerState

## Dash locomotion state. No longer knows about AttackResource — it receives raw
## speed/duration from Player.perform_dash (driven by a DashEffect on a spell), and
## dashes in the player's movement direction.

var dashing_speed : float
var dash_duration : float
var direction : Vector2
var previous_state : String
@onready var collision: CollisionShape2D = $"../../CollisionShape2D"
@onready var collision_shape_2: CollisionShape2D = $"../../HitboxComponent/CollisionShape2D2"

func enter(previous_state_path: String, data := {}) -> void:
	dashing_speed = data.get("speed", 750.0)
	dash_duration = data.get("duration", 0.2)
	direction = player.get_movement()
	if direction == Vector2.ZERO:
		direction = player.last_direction
	previous_state = previous_state_path
	print("DASHING")
	dash()

func dash():
	player.dashing = true
	collision.disabled = true
	collision_shape_2.disabled = true
	var dash_duration_timer = Timer.new()
	add_child(dash_duration_timer)
	dash_duration_timer.start(dash_duration)
	dash_duration_timer.connect("timeout", stop_dash)

func physics_update(_delta: float) -> void:
	player.velocity = direction * dashing_speed
	player.poll_ability_input()
	player.move_and_slide()

func stop_dash():
	player.dashing = false
	collision.disabled = false
	collision_shape_2.disabled = false
	get_child(0).queue_free()
	finished.emit(previous_state)
