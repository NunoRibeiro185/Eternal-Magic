class_name RingPattern extends EmissionPattern

## `count` sub-spells spread evenly around a full circle — a nova that fires outward in
## all directions, independent of aim.

@export var count := 8

func emit(_ctx: CastContext) -> Array:
	var n: int = maxi(count, 1)
	var out := []
	for i in n:
		out.append({ "angle": TAU * float(i) / float(n), "offset": Vector2.ZERO })
	return out
