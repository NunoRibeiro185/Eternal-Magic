class_name Spellbook extends Node

## The caster's loadout + cast machinery, replacing the four copy-pasted spell
## slots on the player. Data-driven (an array of SpellDefinition of any length) and
## caster-agnostic — an enemy adds one too and calls try_cast() aimed at its target.
##
## Owns: per-slot cooldown timers, a single cast-time timer (one cast at a time),
## and cast-lifecycle signals a caster binds to its own feedback (player → cast bar,
## enemy → telegraph). It does not know about UI.

signal cast_started(duration: float)
signal cast_progress(time_left: float)
signal cast_finished()
signal cast_cancelled()
signal slot_fired(index: int)

@export var definitions: Array[SpellDefinition] = []
@export var caster: CasterComponent

var _cooldowns: Array[Timer] = []
var _cast_timer: Timer
var _casting := false
var _pending_index := -1
var _pending_def: SpellDefinition
var _pending_ctx: CastContext

func _ready() -> void:
	_rebuild_cooldowns()
	_cast_timer = Timer.new()
	_cast_timer.one_shot = true
	add_child(_cast_timer)
	_cast_timer.timeout.connect(_on_cast_complete)

## Assign the loadout at runtime (used when definitions are built in code rather
## than in the inspector). Rebuilds the cooldown timers to match.
func set_loadout(defs: Array[SpellDefinition]) -> void:
	definitions = defs
	if is_inside_tree():
		_rebuild_cooldowns()

func _rebuild_cooldowns() -> void:
	for t in _cooldowns:
		t.queue_free()
	_cooldowns.clear()
	for i in definitions.size():
		var t := Timer.new()
		t.one_shot = true
		add_child(t)
		_cooldowns.append(t)

func is_casting() -> bool:
	return _casting

## True while a cast that forbids movement is in progress — the caster reads this
## to root itself (see Player.get_movement).
func movement_locked() -> bool:
	return _casting and _pending_def != null and not _pending_def.can_move_while_casting

func get_cooldown(index: int) -> Timer:
	return _cooldowns[index] if index >= 0 and index < _cooldowns.size() else null

## Hot-swap a slot's spell (used by pickups). Clears that slot's cooldown.
func set_definition(index: int, def: SpellDefinition) -> void:
	if index >= 0 and index < definitions.size():
		definitions[index] = def
		_cooldowns[index].stop()

## Trigger a slot. Rejected if the slot is on cooldown or a cast is already running.
func try_cast(index: int, aim_direction: Vector2, aim_point := Vector2.ZERO) -> void:
	if index < 0 or index >= definitions.size():
		return
	var def := definitions[index]
	if def == null or caster == null or _casting:
		return
	if _cooldowns[index].time_left > 0.0:
		return

	var ctx := caster.build_context(aim_direction, aim_point)
	if def.cast_time <= 0.0:
		_fire(index, def, ctx)
	else:
		_casting = true
		_pending_index = index
		_pending_def = def
		_pending_ctx = ctx
		_cast_timer.start(def.cast_time)
		cast_started.emit(def.cast_time)

func cancel_cast() -> void:
	if _casting:
		_casting = false
		_cast_timer.stop()
		cast_cancelled.emit()

func _process(_delta: float) -> void:
	if _casting:
		cast_progress.emit(_cast_timer.time_left)

func _on_cast_complete() -> void:
	_casting = false
	_fire(_pending_index, _pending_def, _pending_ctx)
	cast_finished.emit()

func _fire(index: int, def: SpellDefinition, ctx: CastContext) -> void:
	SpellLauncher.launch(def, ctx)
	_cooldowns[index].start(def.cooldown)
	slot_fired.emit(index)
