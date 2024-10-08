class_name AttackResource extends Resource

# Basic Values
@export var base_value := 1.0
@export var multiplier := 1.0
@export var travel_speed := 1.0
@export var width := 1.0
@export var height := 1.0
@export var amount := 1 # number of projectiles, aoes, heals, etc
@export var attack_width := 1.0
@export var attack_range := 1.0
@export var has_range : bool
@export var duration := 5.0
@export var has_duration : bool
@export var cooldown := 1.0
@export var charges := 1
@export var cast_time := 0.0
@export var can_move_while_casting : bool

# Element (fire, ice, water, wind, earth, etc.)
@export var element = Utility.Element.Neutral

# Type (dmg, heal, buff, etc.)
@export var type = Utility.Type.None

# Delivery type (aoe, point and click, skillshot, self cast, etc.)
@export var delivery = Utility.Delivery.None

# How will the skillshot manifest (cone, line, targeted, circle, etc.)
@export var shape = Utility.Shape.None
@export var indicator : Indicator

@export var movement_type : Utility.MovementType

# Buff/Debuff
@export var buff : Array[int] = []
@export var debuff : Array[int] = []
@export var buff_duration : Array[float] = []
@export var debuff_duration : Array[float] = []

# Bounce
@export var bounce = false
@export var max_bounce_distance := 1.0
@export var max_bounces := 1
@export var bounce_damage := 0.3

# Pierce
@export var pierce = false
@export var pierce_damage := 0.3

# Homing
@export var homing = false

@export_range(0,100) var impact : int
