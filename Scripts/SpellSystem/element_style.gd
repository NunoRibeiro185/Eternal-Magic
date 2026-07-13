class_name ElementStyle extends Resource

## The full "personality" of an element as tweakable data — not just colour, but how
## its particles behave. Every field is a slider you can tune in the inspector (assign
## an ElementStyle on a SpellDefinition.style) or edit the presets in for_element().
##
## This is what makes the look generative: lightning is sharp/erratic, water is
## round/controlled, fire is soft/erratic/bloomy, earth is muted/heavy — all the same
## particle system, different numbers.

@export_group("Colour")
@export var primary := Color(1, 0.5, 0.2)    ## fill / core colour
@export var secondary := Color(1, 0.85, 0.4) ## bright accent / outline
@export var glow := 1.0

@export_group("Particle behaviour")
@export var particle_size := 16.0        ## soft-dot diameter (px)
@export_range(0.0, 1.0) var softness := 0.8 ## 0 = sharp disc, 1 = very soft blob
@export var speed := 35.0                ## initial particle velocity
@export_range(0.0, 1.0) var speed_randomness := 0.4
@export var spread := 45.0               ## angular spread (deg): low = controlled, high = erratic
@export var turbulence := 0.4            ## 0 = smooth, high = erratic swirl
@export var damping := 0.0               ## slows particles → "controlled"
@export var gravity := Vector2.ZERO      ## drift (up for fire, down for earth)
@export var lifetime := 0.6
@export var additive := true             ## glow (fire/lightning) vs muted (rock/earth)

## Per-element presets. Everything not cased falls back to the @export defaults.
static func for_element(element: int) -> ElementStyle:
	var s := ElementStyle.new()
	match element:
		Utility.Element.Fire: # soft, erratic, bloomy, rising
			s.primary = Color(1.0, 0.45, 0.1); s.secondary = Color(1.0, 0.85, 0.3)
			s.particle_size = 20.0; s.softness = 0.85
			s.speed = 35.0; s.speed_randomness = 0.4; s.spread = 45.0
			s.turbulence = 0.5; s.damping = 0.0; s.gravity = Vector2(0, -30); s.lifetime = 0.6
		Utility.Element.Water: # round, fluid, controlled
			s.primary = Color(0.2, 0.5, 1.0); s.secondary = Color(0.6, 0.9, 1.0)
			s.particle_size = 16.0; s.softness = 0.92
			s.speed = 25.0; s.speed_randomness = 0.2; s.spread = 20.0
			s.turbulence = 0.08; s.damping = 2.5; s.gravity = Vector2.ZERO; s.lifetime = 0.8
		Utility.Element.Ice: # controlled but crisper than water
			s.primary = Color(0.5, 0.9, 1.0); s.secondary = Color(0.9, 1.0, 1.0)
			s.particle_size = 12.0; s.softness = 0.45
			s.speed = 15.0; s.speed_randomness = 0.2; s.spread = 25.0
			s.turbulence = 0.1; s.damping = 2.0; s.lifetime = 0.7
		Utility.Element.Electric: # sharp, fast, erratic
			s.primary = Color(1.0, 0.9, 0.15); s.secondary = Color(1.0, 1.0, 0.75)
			s.particle_size = 8.0; s.softness = 0.12
			s.speed = 130.0; s.speed_randomness = 0.7; s.spread = 90.0
			s.turbulence = 0.9; s.damping = 0.0; s.lifetime = 0.3
		Utility.Element.Earth: # rocky: hard chunks, no swirl, no glow, thrown out and falling
			s.primary = Color(0.27, 0.175, 0.073, 1.0); s.secondary = Color(0.43, 0.257, 0.163, 1.0)
			s.particle_size = 16.0; s.softness = 0.06 # near-hard edges → debris, not cloud
			s.speed = 35.0; s.speed_randomness = 0.6; s.spread = 180.0 # burst outward in all directions
			s.turbulence = 0.03; s.damping = 3.0; s.gravity = Vector2.ZERO # top-down: no "down"; chunks pop and settle
			s.additive = false # muted rock, doesn't glow
		Utility.Element.Poison: # slow, bubbling, controlled
			s.primary = Color(0.5, 0.9, 0.2); s.secondary = Color(0.8, 1.0, 0.4)
			s.particle_size = 16.0; s.softness = 0.85
			s.speed = 18.0; s.spread = 30.0; s.turbulence = 0.2; s.damping = 1.5; s.lifetime = 0.9
		Utility.Element.Grass:
			s.primary = Color(0.3, 0.8, 0.3); s.secondary = Color(0.6, 1.0, 0.5)
			s.particle_size = 14.0; s.softness = 0.6; s.speed = 20.0; s.turbulence = 0.2
		Utility.Element.Air:
			s.primary = Color(0.8, 0.95, 0.9); s.secondary = Color(1, 1, 1)
			s.particle_size = 18.0; s.softness = 0.95; s.speed = 40.0; s.spread = 70.0; s.turbulence = 0.3
		Utility.Element.Light:
			s.primary = Color(1.0, 0.95, 0.7); s.secondary = Color(1, 1, 1)
			s.particle_size = 16.0; s.softness = 0.9; s.speed = 20.0; s.turbulence = 0.15
		Utility.Element.Void:
			s.primary = Color(0.4, 0.1, 0.5); s.secondary = Color(0.75, 0.3, 0.9)
			s.particle_size = 16.0; s.softness = 0.7; s.speed = 25.0; s.turbulence = 0.5; s.damping = 1.0
		_: # Neutral
			s.primary = Color(0.85, 0.85, 0.9); s.secondary = Color(1, 1, 1)
	return s
