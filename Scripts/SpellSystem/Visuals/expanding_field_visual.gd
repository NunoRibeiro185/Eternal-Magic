class_name ExpandingFieldVisual extends SpellVisual

## Fills an EXPANDING AoE with particles that track the hitbox as it grows — a solid
## mass, not a hollow ring. Uses in-polygon emission + SpellExpandingEmitter, so the
## fill scales with the shape without the particles ballooning past the edge. Honours
## the element's `additive` slider (glow vs muted rock).

@export var density := 0.6
@export var point_min := 24
@export var point_max := 400
@export var amount := 1000

func attach(spell: RuntimeSpell, style: ElementStyle, _root: Node2D) -> void:
	if spell.definition.shape == null:
		return
	var poly := spell.definition.shape.build_polygon()
	if poly.size() < 3:
		return

	var minx := poly[0].x; var maxx := poly[0].x
	var miny := poly[0].y; var maxy := poly[0].y
	for pt in poly:
		minx = min(minx, pt.x); maxx = max(maxx, pt.x)
		miny = min(miny, pt.y); maxy = max(maxy, pt.y)
	var area := (maxx - minx) * (maxy - miny)
	var count := clampi(int(area * density), point_min, point_max)
	var points := Vfx.sample_polygon(poly, count, minx, maxx, miny, maxy)
	if points.is_empty():
		return

	var mat := Vfx.build_particle_material(style)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
	mat.emission_point_count = points.size()
	mat.emission_point_texture = Vfx.points_texture(points)
	mat.direction = Vector3(0, 0, 0)
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = minf(style.speed * 0.2, 15.0) # contained; keeps the fill in the shape

	var emitter := SpellExpandingEmitter.new()
	emitter.target = spell
	emitter.base_min = mat.scale_min
	emitter.base_max = mat.scale_max
	emitter.process_material = mat
	emitter.texture = Vfx.soft_dot(int(style.particle_size), style.softness)
	emitter.material = Vfx.blend(style.additive)
	emitter.amount = amount
	emitter.local_coords = true
	spell.add_child(emitter) # under the spell, not the scaled visual root
