@abstract
class_name SpellComponent extends Resource

## A collectible PART of a spell. The game has no authored spells — the player picks
## these up and a spell is ASSEMBLED from whatever they hold. Each part mutates the
## in-progress SpellDefinition during SpellRecipe.build(); a new kind of part is a new
## subclass, and there is no master spell list to edit.
##
## Parts apply in phase order, not pickup order, so a "×2 damage" always lands after the
## damage it scales and a "+2 projectiles" after the form that defines the shot:
##   CORE     — lay down the body: form (shape+movement+emission), element
##   EFFECT   — what it does on contact: damage, status/affliction
##   MODIFIER — tweak what earlier parts produced: ×speed, ×damage, +projectiles, pierce

enum Phase { CORE, EFFECT, MODIFIER }

@export var display_name := "Component" ## shown in inventory / the spell editor
@export var icon: Texture2D             ## inventory / editor icon

## When this part is applied relative to others. Override in modifier/effect parts.
func phase() -> int:
	return Phase.CORE

## Mutate the spell being assembled. Override. `def` already has a castable base.
func apply(_def: SpellDefinition) -> void:
	pass
