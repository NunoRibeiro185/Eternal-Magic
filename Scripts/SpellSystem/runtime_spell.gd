class_name RuntimeSpell extends Area2D

## The live spell in the world. It holds the per-instance mutable state (position,
## age, scale, hit list) and delegates ALL behaviour to its definition's composed
## resources — it never knows what a "fireball" or a "nova" is. Assembled once in
## _ready() from the definition; driven each frame by the movement resource.

var definition: SpellDefinition
var context: CastContext
var direction: Vector2

# Per-instance runtime state the stateless resources read/write.
var age := 0.0
var traveled := 0.0
var hit_scale := 1.0

var _hit_rids: Array = []      # dedupe repeat contacts
var _collision: CollisionShape2D
var _particle: GPUParticles2D
var _visual_root: Node2D        # generated visuals live here; scaled with hit_scale
var style: ElementStyle         # resolved palette, readable by visual layers

func setup(def: SpellDefinition, ctx: CastContext, dir: Vector2) -> void:
	definition = def
	context = ctx
	direction = dir

func _ready() -> void:
	rotation = direction.angle()

	_collision = CollisionShape2D.new()
	if definition.shape:
		_collision.shape = definition.shape.build_shape()
	add_child(_collision)

	if definition.particle_scene:
		_particle = definition.particle_scene.instantiate()
		add_child(_particle)

	# Generated visual layers, in a root that follows the spell's transform + scale.
	_visual_root = Node2D.new()
	add_child(_visual_root)
	style = definition.style if definition.style else ElementStyle.for_element(definition.element)
	for v in definition.visuals:
		v.attach(self, style, _visual_root)

	Factions.apply_targeting(self, context.faction)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	age += delta
	if definition.movement:
		definition.movement.step(self, delta)
	if age >= definition.lifetime or traveled >= definition.max_range:
		_expire()

## Called by ExpandMovement — scales the hitbox (and its matching visual) in place.
func apply_hit_scale() -> void:
	if _collision:
		_collision.scale = Vector2.ONE * hit_scale
	if _visual_root:
		_visual_root.scale = Vector2.ONE * hit_scale

func _on_area_entered(area: Area2D) -> void:
	var target := _resolve_target(area)
	if target == null:
		return
	var rid := area.get_rid()
	if _hit_rids.has(rid):
		return
	_hit_rids.append(rid)

	var hit := _make_hit(target)
	for effect in definition.on_hit:
		effect.apply(hit)

	# Pierce: spark per hit and keep going. Otherwise expire (which fires its own burst).
	if definition.pierce:
		_notify_impact()
	else:
		_expire()

func _expire() -> void:
	if not is_inside_tree():
		return
	var hit := _make_hit(null)
	for effect in definition.on_expire:
		effect.apply(hit)
	_notify_impact()
	queue_free()

func _notify_impact() -> void:
	for v in definition.visuals:
		v.on_impact(self, global_position)

func _make_hit(target: Node2D) -> HitInfo:
	var hit := HitInfo.new()
	# The caster can die while this spell is still in flight (an enemy killed mid-cast),
	# leaving context.caster freed. Assigning a freed object errors, so drop it to null —
	# attribution just becomes "no source", which every consumer already tolerates.
	hit.source = context.caster if is_instance_valid(context.caster) else null
	hit.faction = context.faction
	hit.stats = context.stats
	hit.context = context
	hit.target = target
	hit.spell = self
	return hit

## A target is anything that can take damage. HealthComponent/HitboxComponent will
## grow an apply_damage(amount, hit) method during integration.
func _resolve_target(area: Area2D) -> Node2D:
	if area.has_method("apply_damage"):
		return area
	return null
