class_name GroundDecalVisual extends SpellVisual

## A muted, NON-additive filled shape — a floor telegraph, not a glowing mass. Sits
## under the action and just tints the ground, so AoEs read as an area you're
## affecting rather than a bright blob. Scales with ExpandMovement.

@export var alpha := 0.16

func attach(spell: RuntimeSpell, style: ElementStyle, root: Node2D) -> void:
	if spell.definition.shape == null:
		return
	var poly := spell.definition.shape.build_polygon()
	if poly.size() < 3:
		return
	var fill := Polygon2D.new()
	fill.polygon = poly
	# Normal (mix) blend, low alpha — a muted mark, deliberately NOT additive.
	fill.color = Color(style.primary.r, style.primary.g, style.primary.b, alpha)
	fill.z_index = -2 # on the ground, under particles and actors
	root.add_child(fill)
