class_name CircleHitShape extends HitShape

@export var radius := 16.0
@export var segments := 24

func build_shape() -> Shape2D:
	var s := CircleShape2D.new()
	s.radius = radius
	return s

func build_polygon() -> PackedVector2Array:
	return SpellUtil.draw_circle(segments, radius)
