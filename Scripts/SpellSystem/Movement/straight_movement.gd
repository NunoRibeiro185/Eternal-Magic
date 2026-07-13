class_name StraightMovement extends SpellMovement

## Classic projectile: travel along the spell's direction at a constant speed.

func step(spell: RuntimeSpell, delta: float) -> void:
	var d := spell.direction * speed * delta
	spell.position += d
	spell.traveled += d.length()
