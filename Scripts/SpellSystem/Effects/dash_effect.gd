class_name DashEffect extends SpellEffect

## A self-cast effect: instead of touching a target, it acts on the CASTER. This is
## how "dash" fits the composition model — a spell with no hitbox whose on_cast
## effect moves whoever cast it. The caster implements `perform_dash(speed,
## duration, direction)`; anything that can't dash simply ignores it.

@export var speed := 1500.0
@export var duration := 0.2

func apply(hit: HitInfo) -> void:
	var caster := hit.source
	if caster and caster.has_method("perform_dash"):
		var dir: Vector2 = hit.context.aim_direction if hit.context else Vector2.RIGHT
		caster.perform_dash(speed, duration, dir)
