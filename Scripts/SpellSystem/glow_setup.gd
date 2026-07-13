extends Node

## Autoloaded ("Glow"). Installs a WorldEnvironment with 2D bloom so the additive
## fills / particles / trails / bursts actually glow instead of reading flat. Requires
## HDR 2D (set in project.godot: rendering/viewport/hdr_2d=true) for bright additive
## values to bloom.
##
## To disable: remove the Glow autoload, or set env.glow_enabled = false below.
## Tuning lives here — glow_intensity / glow_strength / glow_bloom / glow_hdr_threshold.

func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS

	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_strength = 0.9
	env.glow_bloom = 0.0          # 0 = no whole-image haze; only bright cores bloom
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 1.1  # only the bright additive cores cross the line → edges stay defined
	# Tighter halo: finer mip levels only, so the glow doesn't smear across the screen.
	env.set_glow_level(1, true)
	env.set_glow_level(2, true)
	env.set_glow_level(3, true)

	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
