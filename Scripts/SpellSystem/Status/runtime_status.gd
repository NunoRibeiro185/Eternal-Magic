class_name RuntimeStatus extends RefCounted

## One live application of a StatusEffect on a target. Holds the mutable per-instance
## state the stateless StatusEffect reads/writes — mirroring RuntimeSpell for movement.
## Because each application is its own RuntimeStatus, statuses STACK independently:
## two burns tick and expire on their own clocks.
##
## Carries attribution (source/faction/stats) captured at apply time, so damage a
## burn deals seconds later still credits the original caster and still scales by the
## stats they had — even if they have since moved on or died.

var effect: StatusEffect
var host: StatusComponent
var source: Node2D
var faction: int
var stats: StatBlock

var remaining: float
var _tick_accum := 0.0

func _init(_effect: StatusEffect, _host: StatusComponent, hit: HitInfo) -> void:
	effect = _effect
	host = _host
	source = hit.source
	faction = hit.faction
	stats = hit.stats
	remaining = effect.duration

## Advance this application by one physics frame, firing on_tick as intervals elapse.
func advance(delta: float) -> void:
	remaining -= delta
	if effect.interval > 0.0:
		_tick_accum += delta
		# `while` (not `if`) so a large delta can't silently swallow ticks.
		while _tick_accum >= effect.interval:
			_tick_accum -= effect.interval
			effect.on_tick(self)

func is_expired() -> bool:
	return remaining <= 0.0

## Convenience for damage-dealing statuses: routes through the host's HealthComponent
## with a HitInfo that preserves the original caster's attribution and stats.
func deal_damage(amount: float) -> void:
	var sink: Node = host.health_component if host else null
	if sink == null or not sink.has_method("apply_damage"):
		return
	var hit := HitInfo.new()
	hit.source = source
	hit.faction = faction
	hit.stats = stats
	hit.target = sink as Node2D
	sink.call("apply_damage", amount, hit)
