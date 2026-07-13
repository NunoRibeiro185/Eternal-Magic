class_name HealthComponent extends Node2D

@export var MAX_HEALTH := 10.0
var health: float

func _ready() -> void:
	health = MAX_HEALTH

func apply_damage(amount: float, hit: HitInfo) -> void:
	health -= amount
	# A DoT can outlive its caster, so guard against a freed source.
	var src_name: String = String(hit.source.name) if is_instance_valid(hit.source) else "<gone>"
	print("[new] ", get_parent().name, " took ", amount, " from ", src_name, " -> health: ", health)
	if health <= 0:
		get_parent().queue_free()
	
