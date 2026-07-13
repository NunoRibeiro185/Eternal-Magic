class_name DamageOverTimeStatus extends StatusEffect

## Periodic damage: burn, poison, bleed, acid — all the SAME mechanic, so they are
## one subclass authored as different data (element + numbers), not a class each.
## Damage scales by the caster's spell_power captured at apply time, matching how
## DamageEffect scales direct hits, so a status is just "damage, spread over time".

@export var damage_per_tick := 2.0

func on_tick(status: RuntimeStatus) -> void:
	var power: float = status.stats.spell_power if status.stats else 1.0
	status.deal_damage(damage_per_tick * power)
