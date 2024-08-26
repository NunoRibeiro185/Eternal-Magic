class_name PointingIndicator extends Indicator

func update(source, mouse_position, delta):
	spawn_point = source.global_position
	direction = (mouse_position - spawn_point).normalized()
	
	if indicator_reference != null:
		point(mouse_position, delta)
		
func point(target, _delta):
	indicator_reference.look_at(target)
	
func set_reference(source, polygon):
	if indicator_reference != null:
		return
	
	var polygon_shape = polygon
	polygon_shape.texture = texture
	polygon_shape.z_index = -1
	indicator_reference = polygon_shape
	source.add_child(polygon_shape)
	
	activated = true
	
func reset():
	if indicator_reference != null:
		indicator_reference.free()
	
	activated = false
