@abstract
class_name EmissionPattern extends Resource

## Base for how many sub-spells spawn and where. Override emit() to return one
## entry per sub-spell: an angle offset (radians, applied to aim_direction) and a
## positional offset from the origin. Single/fan/ring/line/spiral are just
## different subclasses.

## Returns Array[Dictionary] of { "angle": float, "offset": Vector2 }.
func emit(_ctx: CastContext) -> Array:
	return [{ "angle": 0.0, "offset": Vector2.ZERO }]
