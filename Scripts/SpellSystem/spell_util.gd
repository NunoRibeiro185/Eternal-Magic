class_name SpellUtil

## Self-contained helpers the spell package OWNS, so Scripts/SpellSystem depends on no
## host autoload and drops into any project unchanged (see the mechanism-vs-policy
## section in CLAUDE.md). Mirrors the Element enum + the geometry the shapes/styles need.
##
## Element values match the host project's original order exactly, so existing .tres and
## @export_enum ints (element = 1 → Fire, …) keep meaning the same thing.

enum Element { Neutral, Fire, Earth, Air, Water, Electric, Ice, Poison, Grass, Light, Void }

const RECT_START := 32.0 ## a rectangle hitbox begins this far in front of the origin (muzzle gap)

static func draw_circle(points_nb: int, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(points_nb + 1):
		var a := deg_to_rad(i * 360.0 / points_nb - 90)
		points.push_back(Vector2(cos(a), sin(a)) * radius)
	return points

static func draw_cone(points_nb: int, width: float, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var angle := calculate_angle(width, radius)
	points.push_back(Vector2.ZERO)
	for i in range(points_nb + 1):
		var a := i * angle / points_nb - angle / 2.0
		points.push_back(Vector2(cos(a), sin(a)) * radius)
	return points

static func draw_rectangle(width: float, height: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.push_back(Vector2(RECT_START / 2.0, -width / 2.0))
	points.push_back(Vector2(height, -width / 2.0))
	points.push_back(Vector2(height, width / 2.0))
	points.push_back(Vector2(RECT_START / 2.0, width / 2.0))
	return points

static func calculate_angle(width: float, height: float) -> float:
	var a := Vector2(-width / 2.0, height)
	var b := Vector2(width / 2.0, height)
	return b.angle_to(a)
