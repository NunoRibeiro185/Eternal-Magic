class_name HitboxComponent extends Area2D

@export var health_component : HealthComponent
@export var status_component : StatusComponent

func _ready() -> void:
	# Zero-config: grab the sibling StatusComponent if one wasn't wired in the
	# inspector, so entities only need the node dropped in (no NodePath to set).
	if status_component == null:
		status_component = _find_sibling_status()

# RuntimeSpell resolves against this via has_method("apply_damage").
func apply_damage(amount: float, hit: HitInfo) -> void:
	if health_component:
		health_component.apply_damage(amount, hit)

# ApplyStatusEffect resolves against this via has_method("apply_status").
func apply_status(effect: StatusEffect, hit: HitInfo) -> void:
	# Resolve lazily too: a caster (e.g. the Player) may create its StatusComponent
	# in code AFTER this hitbox's _ready ran, so an early lookup would miss it.
	if status_component == null:
		status_component = _find_sibling_status()
	if status_component:
		status_component.apply_status(effect, hit)

func _find_sibling_status() -> StatusComponent:
	var p := get_parent()
	if p == null:
		return null
	for child in p.get_children():
		if child is StatusComponent:
			return child as StatusComponent
	return null
