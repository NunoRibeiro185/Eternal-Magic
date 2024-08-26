class_name AttackRange extends Node

var attack_range : float
var distance_traveled = 0
var last_position : Vector2
var projectile : Projectile

func _init(p):
	projectile = p
	attack_range = projectile.ar.attack_range
	last_position = projectile.spawn_point

func _physics_process(delta: float) -> void:
	distance_traveled += projectile.global_position.distance_to(last_position)
	if distance_traveled >= attack_range:
		projectile.queue_free()
	last_position = projectile.global_position
