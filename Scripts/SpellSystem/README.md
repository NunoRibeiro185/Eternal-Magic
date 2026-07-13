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
| Emission         | `EmissionPattern`   | `SinglePattern`, `FanPattern`, `RingPattern`, `LinePattern` |
| Shape            | `HitShape`          | `Circle`, `Cone`, `Rectangle`, `Triangle` (`…HitShape`) |
| Movement         | `SpellMovement`     | `Straight`, `Expand`, `Wave`, `Accelerate`, `Stationary`, `Homing` (`…Movement`) |
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

## Using this package in another project (host contract)

`Scripts/SpellSystem/` is self-contained: it depends on **no host autoload** (it owns
`SpellUtil` — the `Element` enum + shape geometry) and on **no concrete host class** (damage
and status delivery are duck-typed). To drop it into another game, the host supplies four
things — everything else is the package's job:

1. **A damage sink** — any node with `apply_damage(amount: float, hit: HitInfo)`. `DamageEffect`
   and DoT statuses resolve against it via `has_method`. `HealthComponent` / `HitboxComponent`
   here are *reference* implementations — swap in your own health/armor/death model.
2. **A `StatusComponent`** (optional) under any entity that can be afflicted; it auto-finds the
   sibling damage sink. Only needed for spells that apply statuses.
3. **A caster** — a `CasterComponent` (faction + stats + origin + `rng`) on anything that casts,
   plus a `Spellbook` the host drives via `try_cast()`. The host reads input/AI; **the package
   never reads `Input`**.
4. **Physics layers** matching `Factions` (default 1=Player, 2=Enemies, 3=Walls, 4=Projectiles),
   or remap `Factions.LAYER_*` once at startup.

The host owns **policy** (authority, input, RNG source via `CasterComponent.rng`, persistence,
networking) — see the mechanism-vs-policy section in the root `CLAUDE.md`. Single-player needs
none of it. The package boundary is exactly this folder: to share it, extract `Scripts/SpellSystem/`
to its own git repo and add it back to each project as a submodule (it needn't live under
`addons/` — it isn't an editor plugin). The in-game editor (`Scripts/UI/spell_editor.gd` +
`property_editor.gd`) is optional tooling that can travel with it.

## Not built yet (deliberately)

Silence (blocking casts, vs the movement-only stun), object pooling, aim-mode/telegraph
resources, bounce & orbit movements. The base classes absorb these as new subclasses.
