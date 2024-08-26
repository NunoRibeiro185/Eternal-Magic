class_name Attack extends Node2D

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
	const SHAPE = 0
	const COLLISION = 1
	
	for i in range(0, ar.amount):
		var angle = (i - ar.amount/2) * utils.calculate_angle(ar.attack_width, ar.attack_range) # radians
		var projectile = Projectile.new()
		var shape_and_collision = utils.select_shape(ar.shape, ar.width, ar.height)
		var collision = CollisionShape2D.new()
		var shape = shape_and_collision[SHAPE] as Polygon2D
		var direction = player.global_position.direction_to(get_global_mouse_position())
		
		projectile.direction = direction.rotated(angle)
		
		
		# Collisions
		collision.shape = shape_and_collision[COLLISION]
		projectile.set_collision_mask_value(1, false) #Player
		projectile.set_collision_mask_value(2, true) #Enemies
		projectile.set_collision_mask_value(3, true) #Walls
		projectile.set_collision_layer_value(1, false) #Player
		projectile.set_collision_layer_value(4,true) #Projectiles
		projectile.spawn_point = player.global_position
		projectile.ar = ar
		
		# Duration
		if ar.has_duration:
			projectile.add_child(Duration.new(projectile))
		if ar.has_range:
			projectile.add_child(AttackRange.new(projectile))
			
		projectile.add_child(collision)
		projectile.add_child(shape)
		get_tree().root.call_deferred("add_child", projectile)

func dash():
	state_machine.state.finished.emit("Dashing", {"attack" : ar})
