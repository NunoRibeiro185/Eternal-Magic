extends Resource
class_name  Utils

# Shaders
const FIRE_SHADER = preload("res://Shaders/fire_shader.gdshader")

# Enums
enum Element {Neutral, Fire, Earth, Air, Water, Electric, Ice, Poison, Grass, Light, Void}
enum Type {None, Damage, Heal, Buff, Movement, Parry}
enum Delivery {None, Shot, Dash, AreaFromBelow, AreaFromAbove, Melee, Line, ExplosionOutwards, GlobalFlash}

# Helper functions
func draw_circle(points_nb: int, radius: float) -> Polygon2D:
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	
	for i in range(points_nb + 1):
		var point = deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	polygon.polygon = points
	return polygon
	
