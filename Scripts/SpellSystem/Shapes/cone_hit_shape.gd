class_name ConeHitShape extends HitShape

## Reuses the existing geometry helper in the Utility autoload, proving the new
## shape system can wrap what already works while being swappable per-spell.

@export var width := 64.0
@export var length := 96.0
@export var resolution := 16

func build_shape() -> Shape2D:
	var s := ConvexPolygonShape2D.new()
	s.points = SpellUtil.draw_cone(resolution, width, length)
	return s

func build_polygon() -> PackedVector2Array:
	return SpellUtil.draw_cone(resolution, width, length)
