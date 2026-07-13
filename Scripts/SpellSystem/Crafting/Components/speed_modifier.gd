class_name SpeedModifier extends SpellComponent

## A MODIFIER part: scales the spell's travel speed. Applies after the form, so it works
## on whatever movement the form laid down (the movement was duplicated, so this only
## affects this build).

@export var multiplier := 1.5

func phase() -> int:
	return Phase.MODIFIER

func apply(def: SpellDefinition) -> void:
	if def.movement:
		def.movement.speed *= multiplier
