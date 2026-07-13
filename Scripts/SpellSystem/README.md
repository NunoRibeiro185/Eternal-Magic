# SpellSystem (composition core — WIP)

The next-generation spell system, replacing the flat `AttackResource` + enum-switch
pipeline with **composition**. A spell is assembled from small, swappable Resources
rather than described by one god-object, so new mechanics are new subclasses, never
new fields in a central struct or new branches in a `match`.

## The cast flow

```
Caster (Player/Enemy)
  └─ CasterComponent.build_context(aim)  ──►  CastContext { caster, origin, aim, faction, stats, tree }
												   │
						  SpellLauncher.launch(SpellDefinition, ctx)
												   │
						EmissionPattern.emit(ctx)  →  N × RuntimeSpell
												   │
				RuntimeSpell (Area2D) assembles from the definition:
				  HitShape.build_shape()      → collision (built once)
				  SpellMovement.step(spell,dt) → per-frame behaviour
				  on hit / on expire:  for each SpellEffect → effect.apply(HitInfo)
```

## The seam: `CastContext` + `CasterComponent`

Nothing in the runtime references `Player`. The caster produces a `CastContext`;
the spell only consumes it. The four things that are player-specific today become
*inputs*: **aim** (mouse vs. target), **faction** (drives `Factions.apply_targeting`,
so the same spell hits the right things for player or enemy), **origin**, and
**stats**. Add an `Enemy` with a `CasterComponent` and it casts every existing spell
for free — the only new code is how it resolves aim.

## Composition slots (each = a Resource base + subclasses)

| Slot             | Base                | Examples so far                     |
|------------------|---------------------|-------------------------------------|
| Emission         | `EmissionPattern`   | `FanPattern`                        |
| Shape            | `HitShape`          | `CircleHitShape`, `ConeHitShape`    |
| Movement         | `SpellMovement`     | `StraightMovement`, `ExpandMovement`|
| Effects          | `SpellEffect`       | `DamageEffect`, `SpawnSpellEffect`, `ApplyStatusEffect` |
| Status           | `StatusEffect`      | `DamageOverTimeStatus`, `MovementStatus`, `SpawnOnTickStatus` |

`SpawnSpellEffect` is the recursion: an effect that casts another `SpellDefinition`.
Chaining effects → nested spells is where "infinite spells" actually comes from.

`StatusEffect` is the lingering axis: `ApplyStatusEffect` (an `on_hit` effect) attaches a
stateless `StatusEffect` to whatever was struck, wrapped in a per-target `RuntimeStatus`
(its own clock, so applications stack). A `StatusComponent` on the target ticks them.
Burn and frost are the same `DamageOverTimeStatus` authored as different data — a genuinely
new status is a new subclass. `SpawnOnTickStatus` re-casts a whole `SpellDefinition` from the
target each tick (on_tick isn't damage-only); `MovementStatus` contributes a speed multiplier
(slow / stun) that the target's locomotion reads via `StatusComponent.get_speed_multiplier()`.

## Status

**This is the only spell system.** The old `Scripts/Attacks/` (AttackResource /
SpellManager / enum-switch) pipeline has been deleted. All five player slots run
through here via `Spellbook` + `SpellLibrary`:

| Input | Slot | Shows off |
|-------|------|-----------|
| LMB   | fire fan | `FanPattern` + `StraightMovement` |
| RMB   | flame cone | `ConeHitShape` + `ExpandMovement`, cast-time |
| Q     | piercing lance | `TriangleHitShape`, pierce |
| E     | fire burst | `SpawnSpellEffect` (recursion → nova) |
| Space | dash | `on_cast` `DashEffect` (self-cast, no projectile) |

Enemies can reuse any of these: add a `CasterComponent` (faction = ENEMY) + a
`Spellbook`, and call `try_cast` aimed at the target.

## Not built yet (deliberately)

Silence (blocking casts, vs the movement-only stun), object pooling, aim-mode/telegraph
resources, bounce & homing movements. The base classes absorb these as new subclasses.
