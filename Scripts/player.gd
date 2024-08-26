class_name Player extends CharacterBody2D

const RUNNING_SPEED = 300.0
const DASHING_SPEED = 750
var speed : float
var dashing_speed : float
var input : Vector2
var direction : Vector2

#region onready vars
# Moves
@onready var attack_1: Node = $Attack1
@onready var attack_2: Node = $Attack2
@onready var spell_1: Node = $Spell1
@onready var spell_2: Node = $Spell2
@onready var dodge: Node = $Dodge

@onready var cooldown_a1: Timer = $Attack1/Cooldown_a1
@onready var cooldown_a2: Timer = $Attack2/Cooldown_a2
@onready var cooldown_s1: Timer = $Spell1/Cooldown_s1
@onready var cooldown_s2: Timer = $Spell2/Cooldown_s2
@onready var cooldown_d1: Timer = $Dodge/Cooldown_d1
#endregion

#region Bools
#Cooldowns
var can_a1 := true
var can_a2 := true
var can_s1 := true
var can_s2 := true
var can_d1 := true

# Dashing
var dashing := false
#endregion

# Check for movement inputs
func get_movement():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input.normalized()
	
# Check for abillity inputs
func get_move():
	if Input.is_action_pressed("attack1"):
		if can_a1:
			can_a1 = false
			attack_1.start()
			cooldown_a1.start(attack_1.ar.cooldown)
	if Input.is_action_pressed("attack2"):
		if can_a2:
			can_a2 = false
			attack_2.start()
			cooldown_a2.start(attack_2.ar.cooldown)
	if Input.is_action_pressed("spell1"):
		if can_s1:
			can_s1 = false
			spell_1.start()
			cooldown_s1.start(spell_1.ar.cooldown)
	if Input.is_action_pressed("spell2"):
		if can_s2:
			can_s2 = false
			spell_2.start()
			cooldown_s2.start(spell_2.ar.cooldown)
	if Input.is_action_pressed("dodge"):
		if can_d1:
			can_d1 = false
			dodge.start()
			cooldown_d1.start(dodge.ar.cooldown)
	
#region Cooldown Timers
func _on_cooldown_a_1_timeout() -> void:
	can_a1 = true

func _on_cooldown_a_2_timeout() -> void:
	can_a2 = true

func _on_cooldown_s_1_timeout() -> void:
	can_s1 = true

func _on_cooldown_s_2_timeout() -> void:
	can_s2 = true
	
func _on_cooldown_d_1_timeout() -> void:
	can_d1 = true
#endregion
