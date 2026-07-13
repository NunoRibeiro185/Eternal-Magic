class_name PierceModifier extends SpellComponent

## A MODIFIER part: the spell passes through targets instead of expiring on first hit.

func phase() -> int:
	return Phase.MODIFIER

func apply(def: SpellDefinition) -> void:
	def.pierce = true
