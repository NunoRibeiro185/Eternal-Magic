class_name SpellEditor extends Control

## In-game spell workbench. The LEFT is a live reflective inspector over a real
## SpellDefinition (every exported field, including the ElementStyle sliders, the
## on_cast/on_hit/on_expire effect arrays, and the visuals — full parity with the Godot
## inspector). The RIGHT fires that same definition on a loop, so every edit shows up in
## the preview within a second. Built entirely in code — the scene is just a Control.

var _def: SpellDefinition

var _preview_world: Node2D
var _dummy_caster: Node2D
var _muzzle := Vector2(90, 200)

# A passive target so on-hit sparks show; never dies, absorbs everything.
class _PreviewTarget extends Area2D:
	func apply_damage(_amount: float, _hit: HitInfo) -> void:
		pass
	func apply_status(_effect: StatusEffect, _hit: HitInfo) -> void:
		pass

func _ready() -> void:
	_def = _default_def()
	_build_ui()
	var t := Timer.new()
	t.wait_time = 1.0
	t.timeout.connect(_fire_preview)
	add_child(t)
	t.start()
	_fire_preview()

## A working spell to start editing from, so the preview isn't empty.
func _default_def() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 1.0
	def.lifetime = 1.5
	def.max_range = 500.0
	def.element = SpellUtil.Element.Fire
	var s := CircleHitShape.new()
	s.radius = 12.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 400.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 6.0
	def.on_hit.append(d)
	def.visuals.append(StreamParticleVisual.new())
	def.visuals.append(TrailVisual.new())
	def.visuals.append(BurstVisual.new())
	return def

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	# LEFT: reflective inspector in a scroll view.
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(380, 0)
	root.add_child(left)
	var title := Label.new()
	title.text = "SPELL EDITOR"
	left.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(scroll)

	var inspector := PropertyEditor.new()
	inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inspector)
	# Edits mutate _def in place; the preview reads _def each loop, so no reconnection.
	inspector.edit(_def)

	# RIGHT: looping preview.
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(right)
	var plabel := Label.new()
	plabel.text = "Preview (loops every 1s)"
	right.add_child(plabel)

	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	svc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	svc.custom_minimum_size = Vector2(380, 380)
	right.add_child(svc)

	var sv := SubViewport.new()
	sv.size = Vector2i(400, 400)
	svc.add_child(sv)

	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.1)
	bg.size = Vector2(1200, 1200)
	sv.add_child(bg)

	_preview_world = Node2D.new()
	sv.add_child(_preview_world)

	_dummy_caster = Node2D.new()
	_dummy_caster.position = _muzzle
	_preview_world.add_child(_dummy_caster)

	var target := _PreviewTarget.new()
	target.position = Vector2(320, _muzzle.y)
	target.collision_layer = 0
	target.collision_mask = 0
	target.set_collision_layer_value(Factions.LAYER_ENEMIES, true)
	var cs := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 24.0
	cs.shape = circ
	target.add_child(cs)
	_preview_world.add_child(target)

func _fire_preview() -> void:
	if _def == null or _preview_world == null:
		return
	var ctx := CastContext.new(_dummy_caster, Factions.Team.PLAYER, StatBlock.new(), get_tree())
	ctx.origin = _muzzle
	ctx.aim_direction = Vector2.RIGHT
	ctx.spawn_parent = _preview_world
	SpellLauncher.launch(_def, ctx)
