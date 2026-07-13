class_name SpellLauncher extends RefCounted

## The rebuilt SpellManager.activate(). Pure and caster-agnostic: given a
## definition and a context, it expands the emission pattern and spawns one
## RuntimeSpell per entry. No Player reference, no hardcoded collision — the
## context carries faction, origin, and aim.

static func launch(def: SpellDefinition, ctx: CastContext) -> void:
	if def == null:
		return

	# Self-cast effects (dash, buffs) resolve immediately on the caster.
	if not def.on_cast.is_empty():
		var hit := HitInfo.new()
		hit.source = ctx.caster
		hit.faction = ctx.faction
		hit.stats = ctx.stats
		hit.context = ctx
		for effect in def.on_cast:
			effect.apply(hit)

	# No hitbox shape means no projectile — a pure self-cast stops here.
	if def.shape == null:
		return

	# Spells parent under the caster-supplied node if given (e.g. a preview SubViewport
	# world), otherwise the window root as before.
	var parent: Node = ctx.spawn_parent if ctx.spawn_parent else ctx.tree.root
	var pattern: EmissionPattern = def.emission if def.emission else SinglePattern.new()
	for entry in pattern.emit(ctx):
		var spell := RuntimeSpell.new()
		var dir: Vector2 = ctx.aim_direction.rotated(entry["angle"])
		spell.setup(def, ctx, dir)
		spell.position = ctx.origin + entry["offset"]
		parent.call_deferred("add_child", spell)
