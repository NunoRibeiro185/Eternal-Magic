class_name SpellTrail extends Line2D

## A world-space ribbon that records a moving spell's recent positions. It lives at
## the tree root (not under the spell), so when the spell dies the trail recedes and
## fades instead of popping. Created and styled by TrailVisual.

var target: Node2D    ## the spell we trail behind
var max_points := 20  ## history length

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		# We're at the root (identity transform), so local == global.
		add_point(target.global_position)
		while get_point_count() > max_points:
			remove_point(0)
	else:
		# Spell gone — recede the tail until empty, then remove.
		if get_point_count() > 0:
			remove_point(0)
		else:
			queue_free()
