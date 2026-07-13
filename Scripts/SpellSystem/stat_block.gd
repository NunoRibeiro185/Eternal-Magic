class_name StatBlock extends Resource

## Caster scaling, pulled at cast time so an enemy and the player can share a
## SpellDefinition but scale it differently. Deliberately tiny for now — grow it
## as the damage model grows (crit, penetration, per-element power…).

@export var spell_power := 1.0
@export var crit_chance := 0.0
@export var crit_multiplier := 2.0
