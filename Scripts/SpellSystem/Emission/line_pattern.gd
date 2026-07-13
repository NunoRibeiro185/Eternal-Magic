class_name LinePattern extends EmissionPattern

## `count` sub-spells side by side, perpendicular to the aim — a wall / volley that all
## travel the same way. `spacing` is the gap between them in pixels.

@export var count := 3
@export var spacing := 24.0

func emit(ctx: CastContext) -> Array:
	var n: int = maxi(count, 1)
	var perp := Vector2(-ctx.aim_direction.y, ctx.aim_direction.x)
	var out := []
	for i in n:
		var t := float(i) - float(n - 1) * 0.5 # centre the row on the origin
		out.append({ "angle": 0.0, "offset": perp * t * spacing })
	return out
