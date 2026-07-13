class_name CastContext extends RefCounted

## Everything a spell needs to exist, produced by the CASTER and consumed by the
## spell. Nothing in here is player-specific: an enemy, turret, or trap fills the
## same fields. This is the seam that lets one SpellDefinition be fired by anyone.

var caster: Node2D          ## the actor that cast it (attribution: kills, aggro, scaling)
var origin: Vector2         ## world position the spell spawns from
var aim_direction: Vector2  ## normalized facing — RESOLVED by the caster (mouse / target / pattern)
var aim_point: Vector2      ## world point aimed at (ground-target spells)
var target: Node2D          ## optional locked target (homing / unit-target)
var faction: int            ## Factions.Team — drives friend/foe collision
var stats: StatBlock        ## caster's scaling stats (spell power, crit…)
var tree: SceneTree         ## where to spawn the spell into the world
var spawn_parent: Node      ## optional parent for spawned spells (defaults to tree.root); lets a preview SubViewport hold its own

func _init(_caster: Node2D, _faction: int, _stats: StatBlock, _tree: SceneTree) -> void:
	caster = _caster
	faction = _faction
	stats = _stats
	tree = _tree
