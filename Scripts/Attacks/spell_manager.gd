class_name SpellManager extends Node

var player : Player
var ar : AttackResource

const SHAPE = 0
const COLLISION = 1

func _init(a : AttackResource, p : Player):
	ar = a
	player = p

func activate():
	for i in range(0, ar.amount):
		#General
		var angle: float = (i - ar.amount/2) * Utility.calculate_angle(ar.attack_width, ar.attack_range) # radians
		var spell = Spell.new()
		var shape_and_collision = Utility.select_shape(ar.shape, ar.width, ar.height)
		var collision = CollisionShape2D.new()
		var collision2 = null
		if  ar.movement_type == Utility.MovementType.Wave and ar.shape == Utility.Shape.Circle:
			collision2 = CollisionShape2D.new()
		var shape = shape_and_collision[SHAPE] as Polygon2D
		var direction = player.global_position.direction_to(player.get_global_mouse_position())
		spell.direction = direction.rotated(angle)
		spell.collision = collision
		shape.color = get_element()
		spell.ar = ar
		
		# Collisions
		spell.set_collision_mask_value(1, false) #Player
		spell.set_collision_mask_value(2, true) #Enemies
		spell.set_collision_mask_value(3, true) #Walls
		spell.set_collision_layer_value(1, false) #Player
		spell.set_collision_layer_value(4,true) #Spells
		
		
		
		spell.spawn_point = player.global_position
		
		# Duration
		if ar.has_duration:
			spell.add_child(Duration.new(spell))
		# Range
		if ar.has_range:
			spell.add_child(AttackRange.new(spell))
		
		#Movement Type
		var movement = get_movement_type(spell)
		spell.add_child(movement)
		
		# General
		#spell.add_child(shape)
		
		player.get_tree().root.call_deferred("add_child", spell)

func get_element():
	match ar.element:
		Utility.Element.Neutral:
			return Color.WHITE
		Utility.Element.Fire:
			return Color.ORANGE_RED
		Utility.Element.Water:
			return Color.DARK_BLUE
	
func get_movement_type(spell: Spell):
	match ar.movement_type:
		Utility.MovementType.Instant:
			pass
		Utility.MovementType.Wave:
			var wave_movement = WaveMovement.new(ar, spell)
			return wave_movement
		Utility.MovementType.Projectile:
			var projectile_movement = ProjectileMovement.new(ar, spell)
			return projectile_movement
