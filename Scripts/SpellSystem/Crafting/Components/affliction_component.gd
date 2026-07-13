class_name AfflictionComponent extends SpellComponent

## An EFFECT part that makes the spell apply a lingering StatusEffect on hit (burn,
## frost, slow, stun…). Just wraps the collected status in an ApplyStatusEffect, so the
## whole status system plugs into crafting with no new runtime.

@export var status: StatusEffect

func phase() -> int:
	return Phase.EFFECT

func apply(def: SpellDefinition) -> void:
	if status == null:
		return
	var a := ApplyStatusEffect.new()
	a.status = status
	def.on_hit.append(a)
