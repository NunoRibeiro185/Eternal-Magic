class_name AttackRange extends Node

var attack_range : float
var distance_traveled = 0
var last_position : Vector2
var spell : Spell

func _init(s):
	spell = s
	attack_range = spell.ar.attack_range
	last_position = spell.spawn_point

func _physics_process(delta: float) -> void:
	distance_traveled += spell.global_position.distance_to(last_position)
	if distance_traveled >= attack_range:
		spell.queue_free()
	last_position = spell.global_position
