class_name Vfx extends RefCounted

## Shared generators for the visual layers. The heart of the "generative" look is
## build_particle_material(): it turns an ElementStyle's behaviour sliders into a
## ParticleProcessMaterial, so every element has its own feel from the same system.

## Build a particle process material from an element's behaviour sliders. The caller
## sets the emission shape (ring for streams, points for fills) and direction after.
static func build_particle_material(style: ElementStyle) -> ParticleProcessMaterial:
	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(style.gravity.x, style.gravity.y, 0.0)
	mat.spread = style.spread
	mat.initial_velocity_min = style.speed * (1.0 - clampf(style.speed_randomness, 0.0, 1.0))
	mat.initial_velocity_max = style.speed
	mat.damping_min = style.damping
	mat.damping_max = style.damping
	mat.scale_min = 0.5
	mat.scale_max = 1.0
	mat.scale_curve = _shrink_curve()
	mat.color_ramp = element_ramp(style)
	if style.turbulence > 0.001:
		mat.turbulence_enabled = true
		mat.turbulence_noise_scale = 1.0 + style.turbulence * 2.0
		mat.turbulence_influence_max = style.turbulence
		mat.turbulence_initial_displacement_min = -20.0 * style.turbulence
		mat.turbulence_initial_displacement_max = 20.0 * style.turbulence
	return mat

## Additive glow blend, or null for normal (muted, e.g. rock/earth). Assign to a node's material.
static func blend(additive: bool) -> CanvasItemMaterial:
	if not additive:
		return null # default mix blend — muted, doesn't feed the bloom
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m

## A radial particle sprite. softness 0 = sharp disc (lightning), 1 = soft blob (water/fire).
static func soft_dot(size := 16, softness := 0.8) -> GradientTexture2D:
	var core := clampf(1.0 - softness, 0.0, 0.95) # sharp → large opaque core, hard edge
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(core, Color(1, 1, 1, 1))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = maxi(size, 4)
	tex.height = maxi(size, 4)
	return tex

## Colour over particle life: bright accent → body → fading.
static func element_ramp(style: ElementStyle) -> GradientTexture1D:
	var g := Gradient.new()
	g.set_color(0, style.secondary)
	g.add_point(0.5, style.primary)
	g.set_color(1, Color(style.primary.r, style.primary.g, style.primary.b, 0.4))
	var tex := GradientTexture1D.new()
	tex.gradient = g
	return tex

static func _shrink_curve() -> CurveTexture:
	var c := Curve.new()
	c.add_point(Vector2(0.0, 0.2))
	c.add_point(Vector2(0.3, 1.0))
	c.add_point(Vector2(1.0, 0.0))
	var t := CurveTexture.new()
	t.curve = c
	return t

## Rejection-sample points inside the polygon (not just its bounding box).
static func sample_polygon(poly: PackedVector2Array, k: int, minx: float, maxx: float, miny: float, maxy: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var tries := 0
	var limit := k * 40
	while out.size() < k and tries < limit:
		tries += 1
		var pt := Vector2(randf_range(minx, maxx), randf_range(miny, maxy))
		if Geometry2D.is_point_in_polygon(pt, poly):
			out.append(pt)
	return out

## Points spaced along the polygon's PERIMETER — for hollow ring / shockwave-front looks.
static func edge_points(poly: PackedVector2Array, spacing: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := poly.size()
	if n < 2:
		return pts
	for i in n:
		var a := poly[i]
		var b := poly[(i + 1) % n]
		var seg := b - a
		var steps := maxi(int(seg.length() / maxf(spacing, 1.0)), 1)
		for j in steps:
			pts.append(a + seg * (float(j) / float(steps)))
	return pts

## Pack points into an emission-point texture (each texel is a position).
static func points_texture(points: PackedVector2Array) -> ImageTexture:
	var img := Image.create_empty(points.size(), 1, false, Image.FORMAT_RGBF)
	for i in points.size():
		img.set_pixel(i, 0, Color(points[i].x, points[i].y, 0.0))
	return ImageTexture.create_from_image(img)
