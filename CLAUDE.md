# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

"Endless Magic" (`project.godot` name) is a 2D Godot 4.7 (Forward Plus) action game built around a
**composition-based** spell system: a spell is assembled from small, swappable `Resource`s rather than
described by one big struct, so new mechanics are new `Resource` subclasses — never new fields or new
`match` branches. The design goal ("infinite spells") is that most spells are authored as data
(composed resources / `.tres`) and the same spell can be fired by any caster, player or enemy.

There is no build step, package manager, or test suite — this is a GDScript-only Godot project. Open
and run it via the Godot 4.7 editor (`project.godot` at the repo root, main scene
`res://Scenes/level.tscn`). There is no CLI test/lint command configured.

## Working style in this repo

Claude edits **scripts** (`.gd`); the human edits **scenes/resources** (`.tscn`/`.tres`) in the Godot
editor. Hand-editing serialized scenes is unreliable (uids, cross-references, Godot re-normalizes on
save and can drop manual additions), so prefer: create nodes in code (`add_child` in `_ready`), expose
`@export`s for the human to wire in the inspector, or give the human a short editor recipe. The player's
`Spellbook`, for example, is created in code precisely to avoid depending on a scene node.

## Architecture: the spell system (`Scripts/SpellSystem/`)

A spell is a **`SpellDefinition`** (`spell_definition.gd`) — a `Resource` composed of swappable parts,
each its own `Resource` base class with concrete subclasses:

| Slot | Base (`.gd`) | Subclasses | Role |
|------|------|------------|------|
| Emission | `EmissionPattern` | `FanPattern` | how many sub-spells + their angle/offset |
| Shape | `HitShape` | `CircleHitShape`, `ConeHitShape`, `RectangleHitShape`, `TriangleHitShape` | hitbox geometry, built once |
| Movement | `SpellMovement` | `StraightMovement`, `ExpandMovement` | per-physics-frame behaviour |
| Effects | `SpellEffect` | `DamageEffect`, `SpawnSpellEffect`, `DashEffect`, `ApplyStatusEffect` | what happens on cast/hit/expire |
| Status | `StatusEffect` | `DamageOverTimeStatus`, `MovementStatus`, `SpawnOnTickStatus` | lingering effect attached to a target (burn / slow-stun / periodic re-cast) |

To add a mechanic, add a subclass in the relevant folder (`Emission/`, `Shapes/`, `Movement/`,
`Effects/`) and override its one virtual method — no central switch to touch.

### Cast flow

```
Caster (Player/Enemy) has a CasterComponent + a Spellbook
  Spellbook.try_cast(slot, aim) → cooldown/cast-time gate → CasterComponent.build_context(aim)
    → CastContext { caster, origin, aim_direction, faction, stats, tree }
    → SpellLauncher.launch(SpellDefinition, ctx)
        · on_cast effects resolve on the caster (self-cast: dash, buffs)
        · if the def has a shape: EmissionPattern.emit() → N × RuntimeSpell
            RuntimeSpell (Area2D): HitShape.build_shape() → collision;
              SpellMovement.step() each frame; on area_entered / expire → SpellEffect.apply(HitInfo)
```

- **`CastContext`** (`cast_context.gd`) is the seam: nothing in the runtime references `Player`. The
  caster produces it; the spell consumes it. `aim` is resolved by the caster (player = mouse, enemy =
  toward target).
- **`Factions`** (`factions.gd`) — `apply_targeting(spell, faction)` sets a spawned spell's collision
  layer/mask from the caster's faction (it clears the Area2D defaults first, then sets Projectiles layer
  + Walls + hostile faction). Same `SpellDefinition` hits enemies for the player and the player for an
  enemy. Physics layers: `1=Player, 2=Enemies, 3=Walls, 4=Projectiles, 5=Drops`.
- **`SpawnSpellEffect`** casts another `SpellDefinition` from the point of resolution — the recursion
  that makes nested/combo spells fall out of composition (e.g. bolt → on_expire → expanding nova).
- **`RuntimeSpell`** (`runtime_spell.gd`) holds all per-instance state (age, traveled, hit_scale, hit
  dedupe); the movement/shape resources are stateless and shared. Growth is done by **scaling the
  collision node** (`ExpandMovement`), never by rebuilding polygon points per frame.
- **`Spellbook`** (`spellbook.gd`) is the caster's loadout: an `Array[SpellDefinition]`, per-slot
  cooldown timers, one-cast-at-a-time cast-time handling, and cast-lifecycle signals a caster binds to
  its own UI. Reusable by enemies. `movement_locked()` roots the caster during a no-move cast.

### Who casts

- **Player** (`Scripts/player.gd`): creates its `Spellbook` in `_ready`, loads `SpellLibrary`, polls
  ability input (`poll_ability_input`, called from the locomotion states), builds cast contexts with
  mouse aim, and binds the `Spellbook`'s cast signals to the cast bar + cooldown UI. `perform_dash` is
  called (duck-typed) by `DashEffect` and hands off to the `Dashing` state.
- **`SpellLibrary`** (`spell_library.gd`) builds the five player spells in code (fan / cast-time cone /
  piercing lance / burst-into-nova / dash). These are the reference examples; equivalent `.tres` can be
  authored in the inspector instead.
- **`CasterComponent`** (`caster_component.gd`) + **`StatBlock`** (`stat_block.gd`): drop a
  `CasterComponent` on any actor to make it a caster (faction, stats, muzzle origin, `build_context`).
- **`TestingEnemy`** (`testing_enemy.gd`) is the proof the seam works both ways: it chases the player and
  builds its **own** `CasterComponent` (faction ENEMY) + `Spellbook` in code — the same classes the
  player uses — then fires `SpellLibrary.enemy_loadout()` at the player (aim = toward the target). The
  player takes damage and is slowed/stunned/burned through the identical pipeline; `Factions` supplies
  friend/foe. The only enemy-specific line is how it resolves aim. The player joins group `"Player"` in
  `_ready` so the enemy can find it.

### Status effects (`Scripts/SpellSystem/Status/`)

A **`StatusEffect`** is a lingering effect attached to a target (burn, frost, poison). Like the
movement/shape resources it is stateless and shared; per-instance state (time left, tick clock,
caster attribution) lives in a **`RuntimeStatus`** wrapper — the same stateless-resource + runtime-holder
split as `SpellMovement`/`RuntimeSpell`. Applications **stack independently**: each hit adds its own
`RuntimeStatus` on its own clock. A **`StatusComponent`** (drop it under an entity; it auto-finds the
sibling `HealthComponent`) hosts and ticks them in `_physics_process`. **`ApplyStatusEffect`** is the
`on_hit` `SpellEffect` that attaches one — resolved via the same duck-typed `has_method("apply_status")`
seam as damage (`HitboxComponent` forwards to its `StatusComponent`). Burn/frost are one
`DamageOverTimeStatus` subclass authored as different data, not a class each — a new *kind* of status
is a new subclass. Three exist: `DamageOverTimeStatus` (DoT), `SpawnOnTickStatus` (re-casts a whole
`SpellDefinition` from the target each tick — on_tick isn't damage-only), and `MovementStatus` (slow /
stun). Movement statuses carry no tick; they contribute a `movement_multiplier()` the target's
locomotion reads via `StatusComponent.get_speed_multiplier()` (slows compound, `0.0` = rooted). The
player honours its own (created in code in `player.gd`); `TestingEnemy` (`testing_enemy.gd`) patrols so
the slow/stun is visible. Preventing casting (silence) is still a separate, unwired axis.

### Damage / components

`HitboxComponent` (Area2D) and `HealthComponent` expose `apply_damage(amount, hit: HitInfo)`;
`DamageEffect` finds a target via `has_method("apply_damage")`. `HitInfo` carries `source` (attribution),
`faction`, `stats`, and the originating `CastContext`. Reusable scene components
(`Scenes/Components/*.tscn`), attachable to any entity (see `Entities/testing_enemy.tscn`).

### Pickups / loadout swapping

`SpellCaster` (`Scenes/Items/spell_caster.gd`, group `SpellCasters`) is a pickup Area2D carrying a
`SpellDefinition` (defaults to a library spell if none assigned). `Player._on_collision` →
`swap_spell()` calls `Spellbook.set_definition(slot, def)` and updates the skill-bar icon.

### State machine (locomotion only)

Generic FSM (`Scripts/StateMachine/state_machine.gd`, `state.gd`): states are child `Node`s of type
`State`; transitions happen by a state emitting `finished(next_state_name, data)`, resolved by node-name
lookup — so **state node names must exactly match the string constants** in `player_state.gd`. Casting is
*not* a state anymore — the `Spellbook` handles it outside the FSM. Live states: `idle`, `running`,
`dashing`. (`player_state.gd` still declares unused constants like `CASTING`/`TARTGETING` [sic].)

## Not built yet (deliberately)

Silence (block casting, distinct from the movement-only stun), object pooling,
aim-mode/telegraph resources, bounce & homing movements, richer damage model (resistances/crit beyond
the flat `StatBlock`; elements don't yet interact with a target's resistances), and the
**visual layer** — particles currently don't follow `ExpandMovement`'s scaling or moving hitboxes, so
growing/moving spells look static even though their collision is correct. The `Resource` base classes are
shaped to absorb these as new subclasses. See `Scripts/SpellSystem/README.md`.
