class_name FieldParticleVisual extends SpellVisual

## Fills a spell's SHAPE with element particles emitted from in-polygon points (so it
## respects the borders), built from the element's behaviour sliders. Velocity is
## capped so particles stay inside the form — turbulence supplies the motion, so the
## element's character (erratic vs controlled) still comes through.
##
## Used for AoEs and shaped projectiles that need their form read (cone, nova, lance,
## earth shockwave).

@export var density := 0.4
@export var point_min := 16
@export var point_max := 500
@export var amount := 400

func attach(spell: RuntimeSpell, style: ElementStyle, root: Node2D) -> void:
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
	# Contain the fill: cap velocity so particles stay in the shape; turbulence moves them.
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = minf(style.speed * 0.3, 25.0)

	var p := GPUParticles2D.new()
	p.process_material = mat
	p.texture = Vfx.soft_dot(int(style.particle_size), style.softness)
	p.material = Vfx.blend(style.additive)
	p.amount = amount
	p.local_coords = true # follow the shape and scale with ExpandMovement
	root.add_child(p)
