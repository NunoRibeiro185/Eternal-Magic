class_name CasterComponent extends Node2D

## Drop this on ANY actor that can cast (Player, Enemy, turret). It is the concrete
## implementation of the "caster" contract — it knows the actor's faction, stats,
## and muzzle position, and it builds a CastContext on demand.
##
## Aim is passed IN rather than resolved here, because that is the one thing that
## genuinely differs per caster: the player passes a mouse direction, an enemy
## passes (target - origin). Later this becomes a pluggable AimProvider.

@export var faction: int = Factions.Team.PLAYER
@export var stats: StatBlock

## This caster's randomness stream, handed to every CastContext it builds. Default is a
## local randomized RNG (single-player). A host game wanting determinism (multiplayer,
## replays, seeded runs) can assign a seeded/synced one — the spell code is unaffected.
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	if stats == null:
		stats = StatBlock.new()
	rng.randomize()

## Muzzle / spawn origin. Override by placing this component at the muzzle, or
## swap this for an exported Marker2D later.
func get_cast_origin() -> Vector2:
	return global_position

func build_context(aim_direction: Vector2, aim_point := Vector2.ZERO, target: Node2D = null) -> CastContext:
	var actor: Node2D = owner if owner is Node2D else self
	var ctx := CastContext.new(actor, faction, stats, get_tree())
	ctx.origin = get_cast_origin()
	ctx.aim_direction = aim_direction.normalized()
	ctx.aim_point = aim_point
	ctx.target = target
	ctx.rng = rng
	return ctx
