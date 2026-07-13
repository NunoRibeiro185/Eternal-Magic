class_name Player extends CharacterBody2D

const RUNNING_SPEED = 300.0
var speed : float
var input : Vector2
var direction : Vector2
var custom_cursor_pos = Vector2()
var cursor_radius = 400  # Maximum distance from the player
var last_direction : Vector2

#region onready vars
@onready var skill_bar: SkillBar = $UI/SkillBar
@onready var cast_bar: VBoxContainer = $UI/CastBar

# New composition spell system
@onready var caster: CasterComponent = $CasterComponent
@onready var state_machine: StateMachine = $"State Machine"
var spellbook: Spellbook
var status: StatusComponent  ## created in code; lets movement statuses (slow/stun) affect the player
const CAST_BAR = preload("res://Scenes/UI/cast_bar.tscn")
var _active_cast_bar: TextureProgressBar
#endregion

#region Bools
# Dashing
var dashing := false
#endregion

func _ready() -> void:
	custom_cursor_pos = global_position
	add_to_group("Player") # so enemies can find their target
	status = StatusComponent.new()
	status.name = "StatusComponent"
	add_child(status)
	spellbook = Spellbook.new()
	spellbook.name = "Spellbook"
	spellbook.caster = caster
	add_child(spellbook)
	spellbook.set_loadout(SpellLibrary.player_loadout())
	_bind_skill_bar()
	spellbook.cast_started.connect(_on_cast_started)
	spellbook.cast_progress.connect(_on_cast_progress)
	spellbook.cast_finished.connect(_on_cast_ended)
	spellbook.cast_cancelled.connect(_on_cast_ended)

func _physics_process(delta: float) -> void:
	move_cursor(delta)

# Bind each skill-bar button's cooldown display to its Spellbook cooldown timer.
func _bind_skill_bar() -> void:
	var buttons := [skill_bar.spell_button_1, skill_bar.spell_button_2, skill_bar.spell_button_3, skill_bar.spell_button_4, skill_bar.spell_button_5]
	for i in buttons.size():
		var t := spellbook.get_cooldown(i)
		if t:
			buttons[i].timer = t

func _on_cast_started(duration: float) -> void:
	_active_cast_bar = CAST_BAR.instantiate()
	_active_cast_bar.max_value = duration
	cast_bar.add_child(_active_cast_bar)

func _on_cast_progress(time_left: float) -> void:
	if _active_cast_bar:
		_active_cast_bar.value = time_left

func _on_cast_ended() -> void:
	if _active_cast_bar:
		_active_cast_bar.queue_free()
		_active_cast_bar = null
	
# Check for movement inputs
func get_movement():
	if spellbook and spellbook.movement_locked():
		return Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if input != Vector2.ZERO:
		last_direction = input
	# Movement statuses scale (or zero, when stunned) the player's speed.
	var mult: float = status.get_speed_multiplier() if status else 1.0
	return input.normalized() * mult

# Ability input → Spellbook. Slot indices: 0-3 spells, 4 dash.
func poll_ability_input() -> void:
	if spellbook == null:
		return
	var actions := ["spell1", "spell2", "spell3", "spell4", "dash", "spell5", "spell6"]
	var aim := global_position.direction_to(get_global_mouse_position())
	for i in actions.size():
		if Input.is_action_just_pressed(actions[i]):
			spellbook.try_cast(i, aim, get_global_mouse_position())

# Called by DashEffect (duck-typed) — hands off to the Dashing locomotion state.
func perform_dash(speed: float, duration: float, _dir: Vector2) -> void:
	state_machine.state.finished.emit("Dashing", {"speed": speed, "duration": duration})
	
func move_cursor(delta):
	var cursor_direction = Input.get_vector("cursor_left", "cursor_right", "cursor_up", "cursor_down")
	if cursor_direction.length() > 0.01:
		custom_cursor_pos = cursor_direction * 0.8 * cursor_radius
		# Get the player's current global position
		var target_position = self.get_global_transform_with_canvas().origin + custom_cursor_pos
		print("Player Position:", global_position, " Target Position:", target_position)
		# Warp the mouse to the clamped position
		get_viewport().warp_mouse(clamp(target_position, self.get_global_transform_with_canvas().origin, target_position))
		
	
	
func swap_spell(pickup: SpellCaster) -> void:
	# Pickups replace slot 0 (LMB) with the pickup's SpellDefinition.
	spellbook.set_definition(0, pickup.definition)
	if pickup.sprite and pickup.sprite.texture:
		skill_bar.spell_button_1.texture_normal = pickup.sprite.texture
	pickup.queue_free()

func _on_collision(area: Area2D) -> void:
	if area is SpellCaster:
		swap_spell(area)
		
