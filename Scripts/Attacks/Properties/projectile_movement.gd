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
	collision.shape = Utility.select_shape(ar.shape, ar.width, ar.height)[1]
	spell.collision = collision
	spell.add_child(collision)
