extends Node

# CONSTS
const PLAYER_WIDTH = 32
const CIRCLE_POINT_NB = 32

const SHAPE = 0
const COLLISION = 1

# Shaders
const FIRE_SHADER = preload("res://Shaders/fire_shader.gdshader")

# Enums
enum Element {Neutral, Fire, Earth, Air, Water, Electric, Ice, Poison, Grass, Light, Void}
enum Type {None, Spell, Dash}
enum Delivery {None, Projectile, Dash, Melee, Global, Skillshot, Trail, Selfcast}
enum Shape {None, Cone, Triangle, Circle, Line, Rectangle, Target}
enum Buffs {Damage, Speed, AttackSpeed, Cooldown, Defense, Hp, Shield}
enum MovementType {Instant, Wave, Projectile}

# Helper functions
func draw_circle(points_nb: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
		
	return points
	
func draw_cone(points_nb: int, width: float, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	var angle = calculate_angle(width, radius)
	
	points.push_back(Vector2.ZERO)
	for i in range(points_nb + 1):
		var point = i * angle / points_nb - angle/2
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
		
	return points

func draw_triangle(width : float, height : float) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	points.push_back(Vector2.ZERO)
	points.push_back(Vector2(height, width/2))
	points.push_back(Vector2(height, -width/2))
	
	return points
	
func draw_rectangle(width : float, height : float) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	points.push_back(Vector2(Utility.PLAYER_WIDTH/2, -width/2))
	points.push_back(Vector2(height, -width/2))
	points.push_back(Vector2(height, width/2))
	points.push_back(Vector2(Utility.PLAYER_WIDTH/2, width/2))
	
	return points
	
func calculate_angle(width: float, height: float) -> float:
	var angle : float
	
	var a = Vector2(-width/2, height)
	var b = Vector2(width/2, height)
	
	angle = b.angle_to(a)
	#print("angle: ", rad_to_deg(angle))
	return angle
	
func select_shape(spell_shape : int,  width: float, height: float) -> Array:
	var shape : Polygon2D
	var collision = null
	var points : PackedVector2Array
	
	match spell_shape:
		Shape.Circle:
			points = draw_circle(CIRCLE_POINT_NB, width)
			shape = Polygon2D.new()
			shape.polygon = points
			
			collision = CircleShape2D.new()
			collision.radius = width
		Shape.Triangle:
			points = draw_triangle(width, height)
			shape = Polygon2D.new()
			shape.polygon = points
			
			collision = ConvexPolygonShape2D.new()
			collision.points = points
			
		Shape.Rectangle:
			points = draw_rectangle(width, height)
			shape = Polygon2D.new()
			shape.polygon = points
			
			collision = ConvexPolygonShape2D.new()
			collision.points = points
			
		Shape.Cone:
			points = draw_cone(CIRCLE_POINT_NB/4, width, height)
			shape = Polygon2D.new()
			shape.polygon = points
			
			collision = ConvexPolygonShape2D.new()
			collision.points = points
			
	return [shape, collision]
