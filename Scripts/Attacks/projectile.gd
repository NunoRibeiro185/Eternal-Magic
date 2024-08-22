class_name Projectile extends CharacterBody2D

@onready var ar : AttackResource

func _ready() -> void:
	velocity = global_position.direction_to(get_viewport().get_mouse_position()) * ar.travel_speed
	var timer = Timer.new()
	add_child(timer)
	timer.start(ar.duration)
	timer.connect("timeout", _on_ttl_timeout)

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_ttl_timeout() -> void:
	queue_free()
