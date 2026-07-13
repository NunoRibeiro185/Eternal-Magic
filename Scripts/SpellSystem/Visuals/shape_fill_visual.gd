class_name ShapeFillVisual extends SpellVisual

## Renders the hit shape as a glowing body: an additive Polygon2D fill in the
## element's primary colour plus a Line2D outline in the secondary colour. Built from
## HitShape.build_polygon(), so it matches the collision exactly and — because it
## lives under the spell's visual root — grows with ExpandMovement and moves with the
## projectile (this is what fixes the "stuck" cone visual).

@export var draw_fill := true   ## the flat interior polygon — off for AoEs (looks flat/cartoonish)
@export var draw_outline := true
@export var fill_alpha := 0.22
@export var outline_width := 2.0

func attach(spell: RuntimeSpell, style: ElementStyle, root: Node2D) -> void:
	if spell.definition.shape == null:
		return
	var poly := spell.definition.shape.build_polygon()
	if poly.is_empty():
		return

	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	if draw_fill:
		var fill := Polygon2D.new()
		fill.polygon = poly
		fill.color = Color(style.primary.r, style.primary.g, style.primary.b, fill_alpha)
		fill.material = additive
		root.add_child(fill)

	if not draw_outline:
		return

	var outline := Line2D.new()
	var pts := poly
	pts.append(poly[0]) # close the loop
	outline.points = pts
	outline.width = outline_width
	outline.default_color = style.secondary
	outline.material = additive
	root.add_child(outline)
