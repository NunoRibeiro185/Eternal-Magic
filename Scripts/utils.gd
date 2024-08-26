class_name  Utils extends Resource

# CONSTS
const PLAYER_WIDTH = 32
const CIRCLE_POINT_NB = 32

# Shaders
const FIRE_SHADER = preload("res://Shaders/fire_shader.gdshader")

# Enums
enum Element {Neutral, Fire, Earth, Air, Water, Electric, Ice, Poison, Grass, Light, Void}
enum Type {None, Damage, Heal, Buff, Movement, Parry}
enum Delivery {None, Bullet, Dash, Melee, Global, Skillshot, Trail, Selfcast}
enum SkillshotTypes {None, Cone, Triangle, Circle, Line, Rectangle, Target}
enum Buffs {Damage, Speed, AttackSpeed, Cooldown, Defense, Hp, Shield}

# Helper functions
func draw_circle(points_nb: int, radius: float) -> Polygon2D:
	var polygon = Polygon2D.new()
	var polygon_collision = ConcavePolygonShape2D.new()
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	polygon.polygon = points
	return polygon
	
func draw_cone(points_nb: int, width: float, radius: float) -> Polygon2D:
	var polygon = Polygon2D.new()
	var polygon_collision = ConcavePolygonShape2D.new()
	var points = PackedVector2Array()
	var angle = calculate_angle(width, radius)
	
	points.push_back(Vector2.ZERO)
	
	for i in range(points_nb + 1):
		var point = i * angle / points_nb - angle/2
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	polygon.polygon = points
	return polygon

func draw_triangle(width : float, height : float) -> Polygon2D:
	var polygon = Polygon2D.new()
	var polygon_collision = ConcavePolygonShape2D.new()
	var points = PackedVector2Array()
	
	points.push_back(Vector2.ZERO)
	points.push_back(Vector2(height, width/2))
	points.push_back(Vector2(height, -width/2))
	
	polygon.polygon = points
	
	return polygon
	
func draw_rectangle(width : float, height : float) -> Polygon2D:
	var polygon = Polygon2D.new()
	var polygon_collision = ConcavePolygonShape2D.new()
	var points = PackedVector2Array()
	
	points.push_back(Vector2(Utils.PLAYER_WIDTH/2, -width/2))
	points.push_back(Vector2(height, -width/2))
	points.push_back(Vector2(height, width/2))
	points.push_back(Vector2(Utils.PLAYER_WIDTH/2, width/2))
	
	polygon.polygon = points
	return polygon
	
func calculate_angle(width: float, height: float):
	var angle : float
	
	var a = Vector2(-width/2, height)
	var b = Vector2(width/2, height)
	
	angle = b.angle_to(a)
	print("angle: ", rad_to_deg(angle))
	return angle
