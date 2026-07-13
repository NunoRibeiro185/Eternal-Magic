class_name DamageModifier extends SpellComponent

## A MODIFIER part: scales every DamageEffect the EFFECT parts added. Runs in the
## MODIFIER phase, so it multiplies damage that already exists rather than racing it.

@export var multiplier := 1.5

func phase() -> int:
	return Phase.MODIFIER

func apply(def: SpellDefinition) -> void:
	for e in def.on_hit:
		if e is DamageEffect:
			(e as DamageEffect).base_damage *= multiplier
