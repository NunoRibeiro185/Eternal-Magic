class_name FanPattern extends EmissionPattern

## Even spread of `count` sub-spells across `spread_deg`, symmetric about the aim
## direction for ANY count — fixes the integer-division asymmetry in the old
## SpellManager fan math.

@export var count := 1
@export var spread_deg := 30.0 ## total arc; ignored when count <= 1

func emit(_ctx: CastContext) -> Array:
	if count <= 1:
		return [{ "angle": 0.0, "offset": Vector2.ZERO }]
	var out := []
	var spread := deg_to_rad(spread_deg)
	for i in count:
		var t := float(i) / float(count - 1) - 0.5 # -0.5 .. 0.5
		out.append({ "angle": t * spread, "offset": Vector2.ZERO })
	return out
