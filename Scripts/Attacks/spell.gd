class_name Spell extends Area2D

@onready var ar : AttackResource
var direction : Vector2
var spawn_point : Vector2
var collision: CollisionShape2D
var collision2: CollisionShape2D
var particle: GPUParticles2D
var hit_list = []

func _ready() -> void:
	global_position = spawn_point
	rotation = direction.angle()
	connect("area_entered", _on_collision)

func _on_collision(body):
	if body is HitboxComponent:
		if hit_list.has(body.get_rid()):
			print("Already hit")
			return
		body.damage(self)
		hit_list.append(body.get_rid())
		print("hit list:", hit_list)
	if !ar.pierce:
		spell_free()

func spell_free():
	particle.emitting = false
	if collision:
		collision.disabled = true
	if collision2:
		collision2.disabled = true
	await get_tree().create_timer(3).timeout
	queue_free()
	print("FREE")
