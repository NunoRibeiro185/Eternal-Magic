class_name SinglePattern extends EmissionPattern

## One sub-spell straight along the aim. The plain default when a spell has no other
## emission set — the launcher falls back to this.

func emit(_ctx: CastContext) -> Array:
	return [{ "angle": 0.0, "offset": Vector2.ZERO }]
