class_name Player extends CharacterBody2D

const RUNNING_SPEED = 300.0
const DASHING_SPEED = 750
var speed : float
var dashing_speed : float
var input : Vector2
var direction : Vector2
var custom_cursor_pos = Vector2()
var cursor_radius = 400  # Maximum distance from the player
var last_direction : Vector2

#region onready vars
# Moves
@onready var spell_1: Attack = $Spell1
@onready var spell_2: Attack = $Spell2
@onready var spell_3: Attack = $Spell3
@onready var spell_4: Attack = $Spell4
@onready var dash: Attack = $Dash

@onready var cooldown_s_1: Timer = $Spell1/Cooldown_s1
@onready var cooldown_s_2: Timer = $Spell2/Cooldown_s2
@onready var cooldown_s_3: Timer = $Spell3/Cooldown_s3
@onready var cooldown_s_4: Timer = $Spell4/Cooldown_s4
@onready var cooldown_d: Timer = $Dash/Cooldown_d

@onready var skill_bar: SkillBar = $UI/SkillBar
@onready var cast_bar: VBoxContainer = $UI/CastBar
#endregion

#region Bools
#Cooldowns
var can_s1 := true
var can_s2 := true
var can_s3 := true
var can_s4 := true
var can_d := true

# Dashing
var dashing := false
#endregion

func _ready() -> void:
	custom_cursor_pos = global_position
	
func _physics_process(delta: float) -> void:
	move_cursor(delta)
	
# Check for movement inputs
func get_movement():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if input != Vector2.ZERO:
		last_direction = input
	return input.normalized()

# Check for abillity inputs
func get_move():
	if Input.is_action_pressed("spell1"):
		if can_s1:
			can_s1 = false
			spell_1.start("spell1")
			cooldown_s_1.start(spell_1.ar.cooldown)
	if Input.is_action_pressed("spell2"):
		if can_s2:
			can_s2 = false
			spell_2.start("spell2")
			cooldown_s_2.start(spell_2.ar.cooldown)
	if Input.is_action_pressed("spell3"):
		if can_s3:
			can_s3 = false
			spell_3.start("spell3")
			cooldown_s_3.start(spell_3.ar.cooldown)
	if Input.is_action_pressed("spell4"):
		if can_s4:
			can_s4 = false
			spell_4.start("spell4")
			cooldown_s_4.start(spell_4.ar.cooldown)
	if Input.is_action_pressed("dash"):
		if can_d:
			can_d = false
			dash.start("dash")
			cooldown_d.start(dash.ar.cooldown)
	
func move_cursor(delta):
	var cursor_direction = Input.get_vector("cursor_left", "cursor_right", "cursor_up", "cursor_down")
	print("Cursor: ", cursor_direction)
	if cursor_direction.length() > 0.01:
		custom_cursor_pos = cursor_direction * 0.8 * cursor_radius
		# Get the player's current global position
		var target_position = self.get_global_transform_with_canvas().origin + custom_cursor_pos
		print("Player Position:", global_position, " Target Position:", target_position)
		# Warp the mouse to the clamped position
		get_viewport().warp_mouse(clamp(target_position, self.get_global_transform_with_canvas().origin, target_position))
		
	
#region Cooldown Timers
func _on_cooldown_s_1_timeout() -> void:
	can_s1 = true

func _on_cooldown_s_2_timeout() -> void:
	can_s2 = true

func _on_cooldown_s_3_timeout() -> void:
	can_s3 = true

func _on_cooldown_s_4_timeout() -> void:
	can_s4 = true
	
func _on_cooldown_d_timeout() -> void:
	can_d = true
#endregion

func swap_spell(spell, area):
	print("Ar before: ", spell.ar)
	spell.ar = area.ar
	spell.update_attack()
	print("Ar after: ", spell.ar)
	skill_bar.spell_button_1.texture_normal = area.sprite
	area.queue_free()
	
func _on_collision(area: Area2D) -> void:
	print("Collided")
	if area.is_in_group("SpellCasters"):
		print("replace first spell")
		swap_spell(spell_1, area)
		
