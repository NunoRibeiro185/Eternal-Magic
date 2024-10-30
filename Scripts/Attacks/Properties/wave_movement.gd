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
	original_position = spell.spawn_point
	print("Spell global position: ", original_position)
	
	if ar.shape == Utility.Shape.Circle:
		width = ar.width
		height = ar.height
		
	add_collisions()
	
	if ar.shape == Utility.Shape.Rectangle:
		spell.collision.shape.points = Utility.select_shape(Utility.Shape.Rectangle, ar.width , 0)
		
	if ar.shape == Utility.Shape.Cone:
		width = ar.width
		height = Utility.PLAYER_WIDTH
		spell.collision.shape.points = Utility.select_shape(ar.shape, 0 , height)
		spell.collision2.shape.points = Utility.select_shape(ar.shape, 0 , 0)
	
	
func _physics_process(delta: float) -> void:
	match ar.shape:
		Utility.Shape.Circle:
			spell.collision.shape.radius = width
			spell.collision2.shape.radius = height
			width += ar.travel_speed * delta
			height += ar.travel_speed * delta
			
			if width >= ar.attack_range:
				spell.spell_free()
			
		Utility.Shape.Rectangle:
			spell.global_position += spell.direction * ar.travel_speed * delta
			if original_position.distance_to(spell.global_position) >= ar.attack_range - Utility.PLAYER_WIDTH/2:
				spell.spell_free()
				
		Utility.Shape.Cone:
			spell.collision.shape.points = Utility.select_shape(Utility.Shape.Cone, width , height)
			spell.collision2.shape.points = Utility.select_shape(Utility.Shape.Cone, width , max(height - Utility.PLAYER_WIDTH, 0))
			width = lerpf(0.0, ar.width, height/ar.attack_range)
			height += ar.travel_speed * delta
			if height >= ar.attack_range:
				spell.spell_free()
		
		Utility.Shape.Triangle:
			spell.collision.shape.points = Utility.select_shape(Utility.Shape.Triangle, width , height)
			spell.collision2.shape.points = Utility.select_shape(Utility.Shape.Triangle, width , max(height - Utility.PLAYER_WIDTH, 0))
			width = lerpf(0.0, ar.width, height/ar.attack_range)
			height += ar.travel_speed * delta
			if height >= ar.attack_range:
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
		
	if ar.shape == Utility.Shape.Rectangle:
		collision_shape = ConvexPolygonShape2D.new()
		
	if ar.shape == Utility.Shape.Cone || ar.shape == Utility.Shape.Triangle:
		collision_shape = ConvexPolygonShape2D.new()
		collision_shape2 = ConvexPolygonShape2D.new()
	
	spell.collision.shape = collision_shape
	spell.collision2.shape = collision_shape2
	
	spell.add_child(collision)
	spell.add_child(collision2) 
