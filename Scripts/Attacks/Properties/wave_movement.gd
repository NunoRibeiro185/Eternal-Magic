class_name WaveMovement extends Node

var ar: AttackResource
var spell: Spell
var collision: CollisionShape2D

var width: float
var height: float
var size: float

func _init(attack_resource: AttackResource, sp: Spell) -> void:
	ar = attack_resource
	spell = sp
	collision = spell.collision
	size = height * 0.05
	
	add_collisions()
	if ar.shape == Utility.Shape.Circle and ar.movement_type == Utility.MovementType.Wave:
		width = size
		height = 0
	
func _physics_process(delta: float) -> void:
	match ar.shape:
		Utility.Shape.Circle:
			spell.collision.shape = Utility.select_shape(Utility.Shape.Circle, width, 0)[Utility.COLLISION]
			spell.collision2.shape = Utility.select_shape(Utility.Shape.Circle, height, 0)[Utility.COLLISION]
			width += ar.travel_speed
			height += ar.travel_speed
			
		Utility.Shape.Rectangle:
			spell.collision.shape = Utility.select_shape(Utility.Shape.Rectangle, ar.width , size)[Utility.COLLISION]
			
			
func add_collisions():
	var collision = CollisionShape2D.new()
	var collision2 = CollisionShape2D.new()
	
	spell.collision = collision
	spell.collision2 = collision2
	
	spell.add_child(collision)
	spell.add_child(collision2)
