class_name ProjectileMovement extends Node

var ar: AttackResource
var spell: Spell

func _init(attack_resource: AttackResource, sp: Spell) -> void:
	ar = attack_resource
	spell = sp
	add_collisions()
	
func _physics_process(delta: float) -> void:
	spell.position += spell.direction * ar.travel_speed * delta

func add_collisions():
	var collision = CollisionShape2D.new()
	var collision_shape = null
	if ar.shape == Utility.Shape.Circle:
		collision_shape = CircleShape2D.new()
		collision_shape.radius = ar.width
	else:
		var points = Utility.select_shape(ar.shape, ar.width, ar.height)
		collision_shape = ConvexPolygonShape2D.new()
		collision_shape.points = points
		
	collision.shape = collision_shape
	spell.add_child(collision)
