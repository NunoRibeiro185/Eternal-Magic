class_name WaveMovement extends Node2D

var ar: AttackResource
var spell: Spell
var collision: CollisionShape2D

var width: float
var height: float
var size: float
var original_position: Vector2
func _init(attack_resource: AttackResource, sp: Spell) -> void:
	ar = attack_resource
	spell = sp
	collision = spell.collision
	size = height * 0.05
	original_position = spell.spawn_point
	print("Spell global position: ", original_position)
	if ar.shape == Utility.Shape.Circle:
		width = ar.width
		height = ar.height
		
	add_collisions()
	
	if ar.shape == Utility.Shape.Rectangle:
		spell.collision.shape.points = Utility.select_shape(Utility.Shape.Rectangle, ar.width , size)

	
func _physics_process(delta: float) -> void:
	match ar.shape:
		Utility.Shape.Circle:
			spell.collision.shape.radius = width
			spell.collision2.shape.radius = height
			width += ar.travel_speed * delta
			height += ar.travel_speed * delta
			
			if width >= ar.attack_range:
				spell.spell_free()
				
			print("Inner Radius:", spell.collision.shape.radius)
			print("Outer Radius:", spell.collision2.shape.radius)
			
		Utility.Shape.Rectangle:
			spell.global_position += spell.direction * ar.travel_speed * delta
			print("Distance to: ", original_position.distance_to(spell.global_position))
			if original_position.distance_to(spell.global_position) >= ar.attack_range - ar.width/2:
				spell.spell_free()
			
func add_collisions():
	var collision = CollisionShape2D.new()
	var collision2 = CollisionShape2D.new()
	var collision_shape = null
	var collision_shape2 = null
	
	spell.collision = collision
	spell.collision2 = collision2
	
	if ar.shape == Utility.Shape.Circle:
		collision_shape = CircleShape2D.new()
		collision_shape2 = CircleShape2D.new()
		
		collision_shape.radius = width
		collision_shape2.radius = height
		
	else:
		collision_shape = ConvexPolygonShape2D.new()
	
	spell.collision.shape = collision_shape
	spell.collision2.shape = collision_shape2
	
	spell.add_child(collision)
	spell.add_child(collision2) 
