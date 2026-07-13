class_name DamageComponent extends SpellComponent

## An EFFECT part: makes the spell deal damage. Without one, a spell is harmless (a pure
## utility/knockback/status delivery). Multiple stack — each adds its own DamageEffect.

@export var base_damage := 5.0

func phase() -> int:
	return Phase.EFFECT

func apply(def: SpellDefinition) -> void:
	var d := DamageEffect.new()
	d.base_damage = base_damage
	def.on_hit.append(d)
