class_name HitboxComponent extends Area2D

@export var health_component : HealthComponent

func damage(spell: Spell):
	if health_component:
		health_component.damage(spell)
