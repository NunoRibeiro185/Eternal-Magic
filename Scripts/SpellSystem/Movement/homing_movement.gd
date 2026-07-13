class_name HomingMovement extends SpellMovement

## Curves toward the nearest hostile while flying. `turn_rate` (radians/sec) caps how
## sharply it can steer: high speed + low turn feels like a missile that can be dodged,
## low speed + high turn like a seeker that won't miss. Foe is chosen from the opposing
## faction's group, so the same movement homes correctly for player and enemy casts.

@export var turn_rate := 4.0

func step(spell: RuntimeSpell, delta: float) -> void:
	var target := _nearest_target(spell)
	if target:
		var desired := spell.global_position.direction_to(target.global_position).angle()
		var delta_angle := wrapf(desired - spell.direction.angle(), -PI, PI)
		var max_step := turn_rate * delta
		delta_angle = clampf(delta_angle, -max_step, max_step)
		spell.direction = spell.direction.rotated(delta_angle)
		spell.rotation = spell.direction.angle()

	var d := spell.direction * speed * delta
	spell.position += d
	spell.traveled += d.length()

func _nearest_target(spell: RuntimeSpell) -> Node2D:
	var group := "Player" if spell.context.faction == Factions.Team.ENEMY else "Enemies"
	var best: Node2D = null
	var best_dist := INF
	for n in spell.get_tree().get_nodes_in_group(group):
		if n is Node2D:
			var dist := spell.global_position.distance_squared_to((n as Node2D).global_position)
			if dist < best_dist:
				best_dist = dist
				best = n as Node2D
	return best
