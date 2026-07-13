class_name WaveMovement extends SpellMovement

## Sine weave: travels forward at `speed` while oscillating side to side. `amplitude` is
## the sideways reach in pixels, `frequency` the oscillations per second. Lateral motion
## uses the derivative of the sine so the actual path stays a smooth wave.

@export var amplitude := 40.0
@export var frequency := 3.0

func step(spell: RuntimeSpell, delta: float) -> void:
	var forward := spell.direction * speed * delta
	spell.position += forward
	spell.traveled += forward.length()

	var perp := Vector2(-spell.direction.y, spell.direction.x)
	var w := TAU * frequency
	spell.position += perp * amplitude * w * cos(w * spell.age) * delta
