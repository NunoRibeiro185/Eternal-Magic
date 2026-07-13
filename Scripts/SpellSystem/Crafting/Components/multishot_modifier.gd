class_name MultishotModifier extends SpellComponent

## A MODIFIER part: adds projectiles to the fan. If the form already emits a fan it just
## widens it; otherwise it installs one. Stacks — collect three and the shot count keeps
## climbing.

@export var extra_projectiles := 2
@export var spread_deg := 24.0

func phase() -> int:
	return Phase.MODIFIER

func apply(def: SpellDefinition) -> void:
	var fan := def.emission as FanPattern
	if fan == null:
		fan = FanPattern.new()
		fan.count = 1
		def.emission = fan
	fan.count += extra_projectiles
	fan.spread_deg = spread_deg
