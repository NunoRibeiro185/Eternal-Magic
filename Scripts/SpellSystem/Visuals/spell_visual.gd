class_name SpellVisual extends Resource

## Base for a composable visual layer. A SpellDefinition holds Array[SpellVisual], so
## looks stack (fill + particles + trail + burst). Stateless/shared like the movement
## and shape resources — the per-instance nodes it creates live under the spell's
## visual root (which the RuntimeSpell scales/moves), so they track growth and travel.

## Build this layer's nodes into `root` (a Node2D child of the spell that follows its
## transform and hit_scale). Override.
func attach(_spell: RuntimeSpell, _style: ElementStyle, _root: Node2D) -> void:
	pass

## Called when the spell resolves (hit/expire) at a world position, for impact FX.
func on_impact(_spell: RuntimeSpell, _world_position: Vector2) -> void:
	pass
