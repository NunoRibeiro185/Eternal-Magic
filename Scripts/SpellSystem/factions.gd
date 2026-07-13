class_name Factions extends RefCounted

## Faction identity + the friend/foe rules. This is where "player vs enemy" stops
## being hardcoded: apply_targeting() sets a spawned spell's collision from the
## CASTER's faction, so the exact same SpellDefinition hits the right things
## whether the player or an enemy fired it.

enum Team { PLAYER, ENEMY, NEUTRAL }

# Physics layers mirror project.godot: 1=Player, 2=Enemies, 3=Walls, 4=Projectiles.
const LAYER_PLAYER := 1
const LAYER_ENEMIES := 2
const LAYER_WALLS := 3
const LAYER_PROJECTILES := 4

static func apply_targeting(spell: Area2D, faction: int) -> void:
	# Start clean: a fresh Area2D defaults to layer/mask = 1 (Player), which would
	# make the spell hit its own caster. Clear both, then set only what we intend.
	spell.collision_layer = 0
	spell.collision_mask = 0
	# Every spell lives on the Projectiles layer and always collides with walls.
	spell.set_collision_layer_value(LAYER_PROJECTILES, true)
	spell.set_collision_mask_value(LAYER_WALLS, true)
	match faction:
		Team.PLAYER:
			spell.set_collision_mask_value(LAYER_ENEMIES, true)
		Team.ENEMY:
			spell.set_collision_mask_value(LAYER_PLAYER, true)
		Team.NEUTRAL:
			spell.set_collision_mask_value(LAYER_PLAYER, true)
			spell.set_collision_mask_value(LAYER_ENEMIES, true)
