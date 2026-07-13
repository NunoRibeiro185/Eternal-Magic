class_name SpellDefinition extends Resource

## A spell as COMPOSITION, not a flat struct. Each slot is its own swappable
## Resource; a new mechanic is a new subclass dropped into a slot, never a new
## field here. This replaces the ~40-field AttackResource. Author these as .tres.

@export_group("Cast")
@export var cast_time := 0.0
@export var cooldown := 1.0
@export var charges := 1
@export var can_move_while_casting := false

@export_group("Composition")
@export var emission: EmissionPattern ## how many sub-spells and their layout
@export var shape: HitShape           ## hitbox geometry
@export var movement: SpellMovement   ## per-frame behaviour

@export_group("Effects")
@export var on_cast: Array[SpellEffect] = []    ## resolve immediately on the caster (self-cast: dash, buffs)
@export var on_hit: Array[SpellEffect] = []     ## resolve against a struck target
@export var on_expire: Array[SpellEffect] = []  ## resolve when the spell ends

@export_group("Lifetime")
@export var lifetime := 3.0  ## seconds before auto-expire
@export var max_range := 400.0
@export var pierce := false  ## keep going after a hit

@export_group("Presentation")
@export var element: int = 0 ## Utility.Element — drives the default palette
@export var style: ElementStyle ## optional explicit palette (overrides element default)
@export var visuals: Array[SpellVisual] = [] ## stacked visual layers (fill / particles / trail…)
@export var particle_scene: PackedScene
