class_name ExpandingRingVisual extends SpellVisual

## Perimeter particles for an EXPANDING AoE that stay glued to the hitbox edge as it
## grows — a shockwave ring/front. Uses SpellExpandingEmitter so the ring expands
## with the shape without the particles ballooning past it (the "visual starts further
## out than the hitbox" bug on big AoEs).

@export var spacing := 14.0 ## px between emission points along the edge
@export var amount := 250

func attach(spell: RuntimeSpell, style: ElementStyle, _root: Node2D) -> void:
	if spell.definition.shape == null:
		return
	var poly := spell.definition.shape.build_polygon()
	if poly.size() < 2:
		return
	var points := Vfx.edge_points(poly, spacing)
	if points.is_empty():
		return

	var mat := Vfx.build_particle_material(style)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
	mat.emission_point_count = points.size()
	mat.emission_point_texture = Vfx.points_texture(points)
	mat.direction = Vector3(0, 0, 0)
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = minf(style.speed * 0.15, 10.0) # stay on the front

	var emitter := SpellExpandingEmitter.new()
	emitter.target = spell
	emitter.base_min = mat.scale_min
	emitter.base_max = mat.scale_max
	emitter.process_material = mat
	emitter.texture = Vfx.soft_dot(int(style.particle_size), style.softness)
	emitter.material = Vfx.blend(style.additive)
	emitter.amount = amount
	emitter.local_coords = true
	# Under the spell directly (not the scaled visual root) so we control the scale.
	spell.add_child(emitter)
