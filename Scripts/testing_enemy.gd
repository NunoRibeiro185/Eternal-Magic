class_name TestingEnemy extends CharacterBody2D

## A minimal hostile: it chases the player and casts back, so BOTH directions of the
## status system are exercised in one scene.
##
## As a TARGET it still has a StatusComponent, so the player's spells slow/stun/burn it
## — and because its chase speed reads that multiplier, a slow visibly makes it crawl
## and a stun freezes it mid-approach.
##
## As a CASTER it builds its own CasterComponent (faction ENEMY) + Spellbook in code —
## the exact same classes the player uses — and fires SpellLibrary.enemy_loadout() at
## the player, so the player takes damage, gets slowed/stunned, and burns. It reuses
## the whole spell pipeline for free; the only enemy-specific line is "aim = toward player".

@export var move_speed := 60.0
@export var keep_distance := 200.0 ## stop approaching once this close, so it stays castable
@export var cast_interval := 2.0

var _player: Node2D
@onready var _status: StatusComponent = _find_child_status()
var _caster: CasterComponent
var _spellbook: Spellbook
var _cast_index := 0

func _ready() -> void:
	_player = _find_player()
	_setup_caster()
	var cast_timer := Timer.new()
	cast_timer.wait_time = cast_interval
	cast_timer.timeout.connect(_try_cast)
	add_child(cast_timer)
	cast_timer.start()

func _setup_caster() -> void:
	_caster = CasterComponent.new()
	_caster.name = "CasterComponent"
	_caster.faction = Factions.Team.ENEMY
	add_child(_caster)
	_spellbook = Spellbook.new()
	_spellbook.name = "Spellbook"
	_spellbook.caster = _caster
	add_child(_spellbook)
	_spellbook.set_loadout(SpellLibrary.enemy_loadout())

func _physics_process(_delta: float) -> void:
	var mult: float = _status.get_speed_multiplier() if _status else 1.0
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist > keep_distance:
			velocity = global_position.direction_to(_player.global_position) * move_speed * mult
		else:
			velocity = Vector2.ZERO
	move_and_slide()

# Fires on the cast timer: alternate the enemy's two spells, aimed at the player.
func _try_cast() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
		return
	var aim := global_position.direction_to(_player.global_position)
	_spellbook.try_cast(_cast_index, aim, _player.global_position)
	_cast_index = (_cast_index + 1) % _spellbook.definitions.size()

func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("Player") as Node2D

func _find_child_status() -> StatusComponent:
	for c in get_children():
		if c is StatusComponent:
			return c as StatusComponent
	return null
