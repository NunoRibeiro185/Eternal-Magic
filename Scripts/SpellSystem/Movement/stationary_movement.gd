class_name StationaryMovement extends SpellMovement

## Doesn't move at all — a placed AoE, trap, or lingering field that sits where it was
## cast and expires on lifetime. (`speed` is unused.)

func step(_spell: RuntimeSpell, _delta: float) -> void:
	pass
