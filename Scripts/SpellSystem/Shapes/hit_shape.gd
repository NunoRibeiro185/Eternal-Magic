class_name HitShape extends Resource

## Base for hitbox geometry. Override build_shape() to return a Shape2D built ONCE
## at spawn. Growth/shrink is done by scaling the collision node (see
## ExpandMovement), not by rebuilding points — so this stays a pure factory.

func build_shape() -> Shape2D:
	return null

## The same geometry as a polygon, for the visual layer to render. Empty = no fill.
func build_polygon() -> PackedVector2Array:
	return PackedVector2Array()
