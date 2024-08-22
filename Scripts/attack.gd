extends Node
class_name Attack

@export var ar: AttackResource
@export var utils: Utils
@onready var player: CharacterBody2D = $".."
var type = ""

func update_attack():
	type = ar.type

func start():
	if ar.delivery == utils.Delivery.Shot:
		shoot()
	if ar.delivery == utils.Delivery.Dash:
		dash()
		

func shoot():
	var projectile = Projectile.new()
	var shape = utils.draw_circle(32, ar.size)
	var collision_shape = CircleShape2D.new()
	var collision = CollisionShape2D.new()
	
	collision_shape.radius = ar.size
	collision.shape = collision_shape
	projectile.set_collision_mask_value(1, false)
	projectile.set_collision_mask_value(2, true)
	projectile.set_collision_mask_value(3, true)
	projectile.global_position = player.global_position
	projectile.ar = ar
	
	projectile.add_child(collision)
	projectile.add_child(shape)
	owner.owner.add_child(projectile)

func dash():
	player.dashing = true
	player.dashing_speed = ar.base_value
	var dash_duration = Timer.new()
	add_child(dash_duration)
	dash_duration.start(ar.duration)
	dash_duration.connect("timeout", stop_dash)
	
func stop_dash():
	player.dashing = false
	get_child(1).queue_free()
