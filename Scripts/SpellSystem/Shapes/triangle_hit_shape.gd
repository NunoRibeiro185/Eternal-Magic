class_name TriangleHitShape extends HitShape

## Forward-pointing triangle (wedge). Wraps the existing Utility geometry.

@export var width := 40.0  ## base width (at the back, near the caster)
@export var length := 96.0 ## how far forward the tip reaches

# Arrowhead pointing forward (+X = travel direction): tip ahead, base behind.
func _points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(length, 0.0),        # tip, forward
		Vector2(0.0, width / 2.0),   # base corner
		Vector2(0.0, -width / 2.0),  # base corner
	])

func build_shape() -> Shape2D:
	var s := ConvexPolygonShape2D.new()
	s.points = _points()
	return s

func build_polygon() -> PackedVector2Array:
	return _points()
