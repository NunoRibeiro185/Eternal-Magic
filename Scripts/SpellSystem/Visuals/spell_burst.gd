class_name SpellBurst extends Node2D

## A short-lived impact pop: an expanding, fading ring plus a one-shot radial particle
## burst, both additive and element-colored. Lives at the tree root so it outlives the
## spell that spawned it. Configured and spawned by BurstVisual.

var color := Color.WHITE   ## fill / particle colour (element primary)
var accent := Color.WHITE  ## ring colour (element secondary)
var radius := 40.0
var duration := 0.3

var _age := 0.0
var _ring: Line2D

func _ready() -> void:
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	_ring = Line2D.new()
	_ring.points = _unit_circle(24)
	_ring.width = 3.0
	_ring.default_color = accent
	_ring.material = additive
	add_child(_ring)

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 4.0
	mat.spread = 180.0
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = radius * 2.0
	mat.initial_velocity_max = radius * 4.0
	mat.scale_min = 0.4
	mat.scale_max = 1.0
	mat.color_ramp = _ramp()

	var p := GPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 20
	p.lifetime = duration * 1.5
	p.process_material = mat
	p.texture = Vfx.soft_dot()
	p.material = additive
	add_child(p)

func _process(delta: float) -> void:
	_age += delta
	var t := clampf(_age / duration, 0.0, 1.0)
	_ring.scale = Vector2.ONE * lerpf(0.2, 1.0, t) * radius
	_ring.modulate.a = 1.0 - t
	if _age >= duration * 1.8: # outlast the particle pop
		queue_free()

func _ramp() -> GradientTexture1D:
	var g := Gradient.new()
	g.set_color(0, accent)
	g.set_color(1, Color(color.r, color.g, color.b, 0.0))
	var tex := GradientTexture1D.new()
	tex.gradient = g
	return tex

static func _unit_circle(seg: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in seg + 1:
		var a := TAU * i / seg
		pts.append(Vector2(cos(a), sin(a)))
	return pts
