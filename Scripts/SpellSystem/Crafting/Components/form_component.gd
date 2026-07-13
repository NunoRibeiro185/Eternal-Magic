class_name FormComponent extends SpellComponent

## The "casting type" part: bolt / cone / nova / lance. It bundles the three body slots
## — shape + movement + emission — that together decide how a spell is delivered, plus
## the lifetime/range/cast knobs that go with a form. Swap the Form and the same
## element + damage parts fire completely differently.
##
## The sub-resources are DUPLICATED on apply so later MODIFIER parts (×speed, +shots) can
## safely mutate them for this one build without editing the shared collectible.

@export var shape: HitShape
@export var movement: SpellMovement
@export var emission: EmissionPattern
@export var visuals: Array[SpellVisual] = [] ## optional; replaces the base look (e.g. AoE fields)

@export_group("Form knobs")
@export var pierce := false
@export var lifetime := 1.5
@export var max_range := 500.0
@export var cast_time := 0.0
@export var can_move_while_casting := false

func apply(def: SpellDefinition) -> void:
	if shape:
		def.shape = shape.duplicate() as HitShape
	if movement:
		def.movement = movement.duplicate() as SpellMovement
	if emission:
		def.emission = emission.duplicate() as EmissionPattern
	if not visuals.is_empty():
		var v: Array[SpellVisual] = []
		v.assign(visuals)
		def.visuals = v
	def.pierce = pierce
	def.lifetime = lifetime
	def.max_range = max_range
	def.cast_time = cast_time
	def.can_move_while_casting = can_move_while_casting
