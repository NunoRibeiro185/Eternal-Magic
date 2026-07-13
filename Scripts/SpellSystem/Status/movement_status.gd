class_name MovementStatus extends StatusEffect

## Slow / root / stun as ONE status authored as data: it doesn't tick or deal damage,
## it just contributes a speed multiplier the target's locomotion reads while active.
## multiplier 0.5 = slow, 0.0 = rooted/stunned. Stacks multiply (two 0.5 slows → 0.25),
## and any 0.0 wins outright — so a stun always fully roots regardless of other slows.
##
## Note: this roots MOVEMENT only. Preventing casting (silence) is a separate axis and
## isn't wired yet (see the STUNNED/SILENCED constants in player_state.gd).

@export var multiplier := 0.5

func movement_multiplier() -> float:
	return multiplier
