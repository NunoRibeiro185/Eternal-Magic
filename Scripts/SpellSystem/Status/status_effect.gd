class_name StatusEffect extends Resource

## A lingering effect attached to a target (burn, poison, chill, shock…). Like the
## movement/shape/visual resources it is STATELESS and shared — one authored .tres
## can be applied to many targets. All per-instance state (time remaining, tick
## accumulator, attribution) lives in the RuntimeStatus that wraps it, exactly as
## RuntimeSpell wraps the stateless SpellMovement.
##
## A new lingering mechanic is a new subclass overriding one of the three hooks —
## never a new field on some central StatusManager.

@export var duration := 3.0     ## seconds the status lives on the target
@export var interval := 0.5     ## seconds between on_tick calls; <= 0 = no periodic tick
@export var element: int = 0    ## Utility.Element — for coloured feedback / future resistances

## Fired once when the status is attached.
func on_apply(_status: RuntimeStatus) -> void:
	pass

## Fired every `interval` seconds while active (periodic damage, re-spawns…).
func on_tick(_status: RuntimeStatus) -> void:
	pass

## Fired once when the status expires or is cleared.
func on_remove(_status: RuntimeStatus) -> void:
	pass

## Multiplier this status applies to the host's movement speed (1.0 = none, 0.5 =
## half, 0.0 = rooted/stunned). The host aggregates this across all active statuses;
## non-movement statuses just leave it at 1.0. A query hook, not a switch — the
## locomotion code never asks "what kind of status is this".
func movement_multiplier() -> float:
	return 1.0
