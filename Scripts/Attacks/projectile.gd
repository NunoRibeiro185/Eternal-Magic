class_name Spell extends Area2D

@onready var ar : AttackResource
var direction : Vector2
var spawn_point : Vector2
var collision: CollisionShape2D
var collision2: CollisionShape2D

func _ready() -> void:
	global_position = spawn_point
	rotation = direction.angle()
	connect("body_entered", _on_collision)

func _on_collision(body):
	queue_free()
