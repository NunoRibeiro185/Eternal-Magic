class_name Projectile extends Area2D

@onready var ar : AttackResource
var direction : Vector2
var spawn_point : Vector2
var angle : float

	
func _ready() -> void:
	global_position = spawn_point
	rotation = direction.angle()
	connect("body_entered", _on_collision)
	
func _physics_process(delta: float) -> void:
	position += direction * ar.travel_speed * delta

func _on_collision(body):
	queue_free()
