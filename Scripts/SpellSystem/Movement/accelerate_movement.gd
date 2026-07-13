class_name AccelerateMovement extends SpellMovement

## Straight line, but speed ramps over the spell's life: `acceleration` px/s² added to the
## base `speed`, clamped to [min_speed, max_speed]. Positive = a bolt that winds up;
## negative = one that decays and stalls out.

@export var acceleration := 400.0
@export var min_speed := 0.0
@export var max_speed := 2000.0

func step(spell: RuntimeSpell, delta: float) -> void:
	var current := clampf(speed + acceleration * spell.age, min_speed, max_speed)
	var d := spell.direction * current * delta
	spell.position += d
	spell.traveled += d.length()
