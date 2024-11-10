class_name Attack extends Node2D

@export var ar: AttackResource
@onready var player: CharacterBody2D = $".."
@onready var state_machine: StateMachine = $"../State Machine"
var type = ""
var spell_manager: SpellManager

func _ready():
	spell_manager = SpellManager.new(ar, player)

func update_attack():
	type = ar.type

func start(key):
	if ar.type == Utility.Type.Dash:
		state_machine.state.finished.emit("Dashing", {"attack" : ar})
	if ar.type == Utility.Type.Spell:
		if ar.delivery == Utility.Delivery.Projectile:
			spell_manager.activate()
		elif ar.delivery == Utility.Delivery.Skillshot:
			state_machine.state.finished.emit("Targeting", {"attack" : ar, "spell_manager" : spell_manager, "key" : key})
		
