class_name ExpandMovement extends SpellMovement

## Growing AoE (nova / expanding ring / cone sweep). Crucially this SCALES the
## existing collision node instead of regenerating polygon points every frame —
## which is the fix for the per-frame allocation in the old wave_movement.gd.

@export var max_scale := 5.0
@export var grow_rate := 4.0

func step(spell: RuntimeSpell, delta: float) -> void:
	spell.hit_scale = min(spell.hit_scale + grow_rate * delta, max_scale)
	spell.apply_hit_scale()
