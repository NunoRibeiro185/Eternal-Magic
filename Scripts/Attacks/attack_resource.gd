extends Resource
class_name AttackResource

# Basic Values
@export var base_value := 1.0
@export var multiplier := 1.0
@export var cooldown := 1.0
@export var charges := 1
@export var amount := 1 # number of projectiles, aoes, heals, etc
@export var range := 1.0
@export var cast_time := 1.0
@export var travel_speed := 1.0
@export var size := 1.0
@export var duration := 5.0

# Element (fire, ice, water, wind, earth, etc.)
@export var element = Utils.Element.Neutral

# Type (dmg, heal, buff, etc.)
@export var type = Utils.Type.None

# Delivery type (aoe, point and click, skillshot, self cast, etc.)
@export var delivery = Utils.Delivery.None

# Buff/Debuff
@export var buff = []
@export var debuff = []
@export var buff_duration = []
@export var debuff_duration = []

# Boubnce
@export var bounce = false
@export var max_bounce_distance := 1.0
@export var max_bounces := 1
@export var bounce_damage := 0.3

# Pierce
@export var pierce = false
@export var pierce_damage := 0.3

# Homing
@export var homing = false
