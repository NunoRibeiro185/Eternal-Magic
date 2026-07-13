class_name ApplyStatusEffect extends SpellEffect

## on_hit effect that attaches a lingering StatusEffect to whatever was struck. Same
## duck-typed seam as DamageEffect: the target just needs an apply_status(effect, hit)
## method (HitboxComponent forwards to its sibling StatusComponent). A spell "burns"
## purely as data — append this to on_hit with a DamageOverTimeStatus, no new code.

@export var status: StatusEffect

func apply(hit: HitInfo) -> void:
	if status == null or hit.target == null:
		return
	if hit.target.has_method("apply_status"):
		hit.target.apply_status(status, hit)
