class_name StatusComponent extends Node

## Hosts the active StatusEffects on one actor and ticks them. Drop this node under
## any entity that can be burned/poisoned/chilled (same "attachable component" model
## as HealthComponent / HitboxComponent). Statuses stack independently — each call to
## apply_status() adds its own RuntimeStatus with its own clock.
##
## Zero-config wiring: if health_component isn't set in the inspector it grabs the
## sibling HealthComponent automatically, so you only have to drop the node in.

@export var health_component: HealthComponent

var _active: Array[RuntimeStatus] = []

func _ready() -> void:
	if health_component == null:
		health_component = _find_sibling_health()

## Attach a new independent application of `effect`. `hit` carries the caster
## attribution/stats that the status will keep for its whole lifetime.
func apply_status(effect: StatusEffect, hit: HitInfo) -> void:
	if effect == null:
		return
	var rs := RuntimeStatus.new(effect, self, hit)
	_active.append(rs)
	effect.on_apply(rs)

## Aggregate speed multiplier from every active status (1.0 = unaffected). The actor's
## locomotion multiplies its speed by this — slows compound, a stun (0.0) roots. No
## type check: every StatusEffect answers movement_multiplier(), most just return 1.0.
func get_speed_multiplier() -> float:
	var m := 1.0
	for rs in _active:
		m *= rs.effect.movement_multiplier()
	return m

## World position of the hosting entity, for statuses that spawn things (SpawnOnTick).
func get_world_position() -> Vector2:
	var p := get_parent()
	if p is Node2D:
		return (p as Node2D).global_position
	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	if _active.is_empty():
		return
	for rs in _active:
		rs.advance(delta)
	# Reverse iterate so removals don't shift the indices we still have to visit.
	for i in range(_active.size() - 1, -1, -1):
		if _active[i].is_expired():
			_active[i].effect.on_remove(_active[i])
			_active.remove_at(i)

func _find_sibling_health() -> HealthComponent:
	var p := get_parent()
	if p == null:
		return null
	for child in p.get_children():
		if child is HealthComponent:
			return child as HealthComponent
	return null
