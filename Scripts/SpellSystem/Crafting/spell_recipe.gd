class_name SpellRecipe extends Resource

## An equipped spell is not an authored asset — it's this: an ordered bag of collected
## SpellComponents that BUILDS into a castable SpellDefinition. Rebuild whenever the
## parts change (a pickup, an edit in the spell editor) and hand the result to
## Spellbook.set_definition(). Because build() starts from a fixed base, a half-finished
## recipe (say, only an element and no form yet) still casts a plain bolt instead of
## erroring — which is exactly what you want while the player is mid-collection.

@export var components: Array[SpellComponent] = []
@export var cooldown := 1.0 ## the recipe's own cadence; parts don't set this

func build() -> SpellDefinition:
	var def := _base()
	# Apply in phase order (CORE → EFFECT → MODIFIER), not collection order, so "×2
	# damage" always lands after the damage it scales. Only three phases, so a simple
	# pass per phase beats sorting.
	for p in [SpellComponent.Phase.CORE, SpellComponent.Phase.EFFECT, SpellComponent.Phase.MODIFIER]:
		for c in components:
			if c and c.phase() == p:
				c.apply(def)
	return def

## A minimal castable spell so an empty/partial recipe still does something visible.
func _base() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = cooldown
	def.lifetime = 1.5
	def.max_range = 500.0
	var s := CircleHitShape.new()
	s.radius = 10.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 400.0
	def.movement = m
	# Default look so any assembled spell is visible; a FormComponent can replace it.
	def.visuals.append(StreamParticleVisual.new())
	def.visuals.append(TrailVisual.new())
	def.visuals.append(BurstVisual.new())
	return def
