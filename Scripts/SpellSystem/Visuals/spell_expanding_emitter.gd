class_name SpellExpandingEmitter extends GPUParticles2D

## A particle emitter for expanding AoEs that tracks the hitbox correctly. The problem
## it solves: if particles just ride the spell's scaled visual root, their SPRITES
## balloon with the scale and spill past the edge. Here we scale the emitter for
## POSITION (so emission points ride the growing edge) but counter-scale the material
## so each particle keeps a constant on-screen size. Lives under the spell directly,
## not under the scaled visual root.

var target: RuntimeSpell
var base_min := 0.5 ## material scale_min at hit_scale 1
var base_max := 1.0 ## material scale_max at hit_scale 1

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		return
	var s := maxf(target.hit_scale, 0.001)
	scale = Vector2.ONE * s # emission points ride the growing edge
	var m := process_material as ParticleProcessMaterial
	if m:
		# node scale (s) × material scale (base/s) = base → constant sprite size
		m.scale_min = base_min / s
		m.scale_max = base_max / s
