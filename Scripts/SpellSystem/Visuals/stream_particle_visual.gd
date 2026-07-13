class_name StreamParticleVisual extends SpellVisual

## Streams element particles behind a flying projectile (world-space), built entirely
## from the element's behaviour sliders — no fixed fire template. Fire streams
## soft/erratic, lightning sharp/fast/erratic, water round/controlled, etc.

@export var amount := 200

func attach(_spell: RuntimeSpell, style: ElementStyle, root: Node2D) -> void:
	var mat := Vfx.build_particle_material(style)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 5.0
	mat.direction = Vector3(-1, 0, 0) # backward relative to travel → a streaming trail

	var p := GPUParticles2D.new()
	p.process_material = mat
	p.texture = Vfx.soft_dot(int(style.particle_size), style.softness)
	p.material = Vfx.blend(style.additive)
	p.amount = amount
	p.lifetime = style.lifetime
	p.local_coords = false # world space, so it streams behind as the spell flies
	root.add_child(p)
