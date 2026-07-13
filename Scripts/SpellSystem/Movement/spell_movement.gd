@abstract
class_name SpellMovement extends Resource

## Base for how a spell moves/behaves each physics frame. Override step(). The
## movement is STATELESS and shared — per-instance state (position, age, scale)
## lives on the RuntimeSpell, so the same resource drives many live spells.

@export var speed := 200.0

func step(_spell: RuntimeSpell, _delta: float) -> void:
	pass
