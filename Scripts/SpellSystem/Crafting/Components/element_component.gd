class_name ElementComponent extends SpellComponent

## The element part. Sets SpellDefinition.element, which drives the generative
## ElementStyle palette + particle behaviour (ElementStyle.for_element) — so picking up
## a different element visibly re-skins whatever spell you're holding, for free.

@export_enum("Neutral", "Fire", "Earth", "Air", "Water", "Electric", "Ice", "Poison", "Grass", "Light", "Void") var element: int = SpellUtil.Element.Fire

func apply(def: SpellDefinition) -> void:
	def.element = element
