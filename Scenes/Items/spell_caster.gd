class_name SpellCaster extends Area2D

## A world pickup that grants a spell. Carries a SpellDefinition (composition), not
## an AttackResource. Assign one in the inspector, or leave it empty to use a code
## default so existing placed pickups keep working.

@export var definition: SpellDefinition
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if definition == null:
		definition = SpellLibrary.fire_burst()
