class_name SpawnSpellEffect extends SpellEffect

## The recursion that makes the system open-ended: an effect that casts ANOTHER
## SpellDefinition from the point of resolution, keeping the original caster and
## faction. Chain these for combos — a projectile whose on_expire spawns an AoE
## whose on_hit applies a burn whose on_tick spawns... etc.

@export var spell: SpellDefinition
@export var inherit_direction := true

func apply(hit: HitInfo) -> void:
	if spell == null:
		return
	# Prefer the live spell's position/direction; fall back to the cast context
	# (so this also works from on_cast, where there is no spawned spell yet).
	var tree: SceneTree = hit.spell.get_tree() if hit.spell else (hit.context.tree if hit.context else null)
	if tree == null:
		return
	var ctx := CastContext.new(hit.source, hit.faction, hit.stats, tree)
	if hit.context:
		ctx.rng = hit.context.rng # keep the same randomness stream through the recursion
	if hit.spell:
		ctx.origin = hit.spell.global_position
		ctx.aim_direction = hit.spell.direction if inherit_direction else Vector2.RIGHT
	else:
		ctx.origin = hit.context.origin
		ctx.aim_direction = hit.context.aim_direction if inherit_direction else Vector2.RIGHT
	SpellLauncher.launch(spell, ctx)
