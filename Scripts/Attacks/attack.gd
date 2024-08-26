class_name Attack extends Node

@export var ar: AttackResource
@export var utils: Utils
@onready var player: CharacterBody2D = $".."
@onready var state_machine: StateMachine = $"../State Machine"
var type = ""

func update_attack():
	type = ar.type

func start():
	if ar.delivery == utils.Delivery.Bullet:
		shoot()
	if ar.delivery == utils.Delivery.Dash:
		dash()
	if ar.delivery == utils.Delivery.Skillshot:
		state_machine.state.finished.emit("Targeting", {"attack" : ar})
		
func shoot():
	var projectile = Projectile.new()
	var shape = utils.draw_circle(5, ar.size)
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
	state_machine.state.finished.emit("Dashing", {"attack" : ar})
