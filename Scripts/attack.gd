extends Node

@export var attack_resource: AttackResource
@export var utils: Utils
@onready var player: CharacterBody2D = $".."
const FIRE_SHADER = preload("res://Shaders/fire_shader.gdshader")
var type = ""

func update_attack():
	type = attack_resource.type

func start():
	if attack_resource.delivery == utils.Delivery.Shot:
		fire_shot()
		

func fire_shot():
	var projectile = Projectile.new()
	var shape = utils.draw_circle(32, attack_resource.size)
	var collision = CollisionShape2D.new()
	var shader = ShaderMaterial.new()
	shader.shader = FIRE_SHADER
	collision.shape = shape
	projectile.set("material/0", shader)
	projectile.global_position = player.global_position
	projectile.add_child(collision)
	projectile.add_child(shape)
	projectile.attack_resource = attack_resource
	owner.owner.add_child(projectile)
