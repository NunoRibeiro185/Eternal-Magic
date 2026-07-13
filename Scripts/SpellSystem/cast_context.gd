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

var rng: RandomNumberGenerator ## randomness source for GAMEPLAY rolls; injected by the caster (see get_rng)

func _init(_caster: Node2D, _faction: int, _stats: StatBlock, _tree: SceneTree) -> void:
	caster = _caster
	faction = _faction
	stats = _stats
	tree = _tree

## The randomness source effects must use for GAMEPLAY rolls (crit, spread jitter) —
## never global randf(). This is a POLICY seam: single-player leaves the caster's default
## RNG; a multiplayer or replay game injects a seeded/synced one and gets identical
## results on every peer, with zero changes to the spell code. Falls back to one shared
## randomized RNG so effects never have to null-check.
func get_rng() -> RandomNumberGenerator:
	return rng if rng else default_rng()

static var _default_rng: RandomNumberGenerator

static func default_rng() -> RandomNumberGenerator:
	if _default_rng == null:
		_default_rng = RandomNumberGenerator.new()
		_default_rng.randomize()
	return _default_rng
