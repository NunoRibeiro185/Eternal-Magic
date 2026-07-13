class_name SpawnOnTickStatus extends StatusEffect

## Proof that on_tick isn't damage-only: every interval this casts a whole
## SpellDefinition from the host's position, reusing the original caster's faction and
## stats. "Burn that periodically erupts", "poison cloud that re-seeds", a DoT that
## drops a nova each second — all fall out of composition, no new pipeline. Because
## the spawned spell is itself a full definition, it can carry its own effects (just
## don't have it re-apply this status, or it recurses without bound).

@export var spell: SpellDefinition

func on_tick(status: RuntimeStatus) -> void:
	if spell == null or status.host == null:
		return
	var tree := status.host.get_tree()
	if tree == null:
		return
	var ctx := CastContext.new(status.source, status.faction, status.stats, tree)
	ctx.origin = status.host.get_world_position()
	ctx.aim_direction = Vector2.RIGHT # AoEs ignore it; a directional spawn can set its own
	SpellLauncher.launch(spell, ctx)
