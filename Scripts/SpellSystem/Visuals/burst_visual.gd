class_name BurstVisual extends SpellVisual

## Spawns a SpellBurst at the point of impact/expiry — the "juice" when a spell lands.
## Spawned into the tree root so it survives the spell being freed.

@export var radius := 10.0
@export var duration := 0.3

func on_impact(spell: RuntimeSpell, world_position: Vector2) -> void:
	var burst := SpellBurst.new()
	if spell.style:
		burst.color = spell.style.primary
		burst.accent = spell.style.secondary
	burst.radius = radius
	burst.duration = duration
	burst.position = world_position # spawn world is identity, so position == world
	spell.spawn_world().call_deferred("add_child", burst)
