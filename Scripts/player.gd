extends CharacterBody2D


const SPEED = 300.0

var input : Vector2

# Moves
@onready var attack_1: Node = $Attack1
@onready var attack_2: Node = $Attack2
@onready var spell_1: Node = $Spell1
@onready var spell_2: Node = $Spell2
@onready var dodge: Node = $Dodge

func _physics_process(_delta: float) -> void:

	var playerInput = get_movement()
	velocity = playerInput * SPEED 
	
	get_move()
	move_and_slide()

func get_movement():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input.normalized()
	
func get_move():
	if Input.is_action_just_pressed("attack1"):
		attack_1.start()
	if Input.is_action_just_pressed("attack2"):
		attack_2.start()
	if Input.is_action_just_pressed("spell1"):
		spell_1.start()
	if Input.is_action_just_pressed("spell2"):
		spell_2.start()
	if Input.is_action_just_pressed("dodge"):
		dodge.start()
	
