class_name TrailVisual extends SpellVisual

## A motion trail for moving projectiles — the streaming look the old fire had. It
## builds a world-space Line2D (SpellTrail) that tapers from thin/transparent at the
## tail to thick/bright at the head, additive-blended and colored by the element.
## Add it only to spells that actually move.

@export var width := 10.0
@export var points := 20 ## how many frames of history the ribbon keeps

func attach(spell: RuntimeSpell, style: ElementStyle, _root: Node2D) -> void:
	var trail := SpellTrail.new()
	trail.target = spell
	trail.max_points = points
	trail.width = width
	trail.z_index = -1 # behind the spell body

	# Taper: thin at the tail (0), full width at the head (1).
	var wc := Curve.new()
	wc.add_point(Vector2(0.0, 0.0))
	wc.add_point(Vector2(1.0, 1.0))
	trail.width_curve = wc

	# Fade: transparent at the tail, bright element colour at the head.
	var grad := Gradient.new()
	grad.set_color(0, Color(style.primary.r, style.primary.g, style.primary.b, 0.0))
	grad.set_color(1, style.secondary)
	trail.gradient = grad

	trail.joint_mode = Line2D.LINE_JOINT_ROUND
	trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail.end_cap_mode = Line2D.LINE_CAP_ROUND

	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	trail.material = additive

	# World-space: parent to the tree root so it survives the spell's death.
	spell.get_tree().root.call_deferred("add_child", trail)
