class_name DamageEffect extends SpellEffect

## Deal damage scaled by the caster's StatBlock. Targets are expected to expose
## `apply_damage(amount: float, hit: HitInfo)` — HealthComponent gains that method
## during integration (it currently reads spell.ar directly).

@export var base_damage := 1.0
@export_enum("Neutral", "Fire", "Earth", "Air", "Water", "Electric", "Ice", "Poison", "Grass", "Light", "Void") var element: int = 0

func apply(hit: HitInfo) -> void:
	if hit.target == null:
		return
	var amount := base_damage * hit.stats.spell_power
	if randf() < hit.stats.crit_chance:
		amount *= hit.stats.crit_multiplier
	if hit.target.has_method("apply_damage"):
		hit.target.apply_damage(amount, hit)
