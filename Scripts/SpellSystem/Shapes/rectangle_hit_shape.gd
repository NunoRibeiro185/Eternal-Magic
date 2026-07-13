class_name RectangleHitShape extends HitShape

## Forward-extending rectangle (beam / lash). Wraps the existing Utility geometry
## so it extends from the caster outward along the spell's facing.

@export var width := 40.0  ## thickness across the beam
@export var length := 96.0 ## how far forward it reaches

func build_shape() -> Shape2D:
	var s := ConvexPolygonShape2D.new()
	s.points = Utility.draw_rectangle(width, length)
	return s

func build_polygon() -> PackedVector2Array:
	return Utility.draw_rectangle(width, length)
