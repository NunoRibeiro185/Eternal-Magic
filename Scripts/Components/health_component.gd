class_name HealthComponent extends Node2D

@export var MAX_HEALTH := 10.0
var health: float

func _ready() -> void:
	health = MAX_HEALTH

func damage(spell: Spell):
	health -= spell.ar.base_value * spell.ar.multiplier
	print("health: ", health)
	if health <= 0:
		get_parent().queue_free()
	
