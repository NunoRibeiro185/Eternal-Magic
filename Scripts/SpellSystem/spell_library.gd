class_name SpellLibrary extends RefCounted

## Code-built loadout replacing the five old AttackResource slots. Each entry is a
## pure composition — the same thing an authored .tres would hold. Deliberately
## varied so every composition slot (emission / shape / movement / effects / visuals)
## and the recursion + self-cast paths are exercised in one hand.

## Fill + generated particle field, the standard two visual layers for a shaped spell.
# Shaped projectiles (the lance): thin outline + filled particles so the form reads.
static func _add_visuals(def: SpellDefinition) -> void:
	var edge := ShapeFillVisual.new()
	edge.draw_fill = false # outline only
	def.visuals.append(edge)
	def.visuals.append(FieldParticleVisual.new())

# AoEs: a muted floor telegraph + a filled expanding mass that tracks the hitbox.
# (ExpandingRingVisual stays available for spells that want a hollow shockwave front.)
static func _add_aoe_visuals(def: SpellDefinition) -> void:
	def.visuals.append(GroundDecalVisual.new())
	def.visuals.append(ExpandingFieldVisual.new())

## A short, hot fire DoT — authored data, not a subclass. Fresh instance per spell so
## tuning one doesn't leak into another (Resources are shared by reference).
static func _burn() -> DamageOverTimeStatus:
	var s := DamageOverTimeStatus.new()
	s.element = Utility.Element.Fire
	s.duration = 3.0
	s.interval = 0.5
	s.damage_per_tick = 2.0
	return s

## A long, low frostbite DoT. Applied fresh per hit, so spamming the fast-cooldown
## piercing lance STACKS several independent frost ticks on the same target.
static func _frost() -> DamageOverTimeStatus:
	var s := DamageOverTimeStatus.new()
	s.element = Utility.Element.Ice
	s.duration = 5.0
	s.interval = 1.0
	s.damage_per_tick = 1.5
	return s

## A heavy slow (earth): 40% speed for 2.5s. No tick, no damage — pure locomotion.
static func _slow() -> MovementStatus:
	var s := MovementStatus.new()
	s.element = Utility.Element.Earth
	s.duration = 2.5
	s.interval = 0.0
	s.multiplier = 0.4
	return s

## A brief full stun (lightning): rooted for 0.6s (multiplier 0.0).
static func _stun() -> MovementStatus:
	var s := MovementStatus.new()
	s.element = Utility.Element.Electric
	s.duration = 0.6
	s.interval = 0.0
	s.multiplier = 0.0
	return s

## The spell an ember re-casts each tick: a tiny fire nova. Deliberately plain
## (damage only, no status) so the SpawnOnTick loop can't recurse into itself.
static func _ember_nova() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.lifetime = 0.35
	def.pierce = true
	def.element = Utility.Element.Fire
	var s := CircleHitShape.new()
	s.radius = 8.0
	def.shape = s
	var m := ExpandMovement.new()
	m.max_scale = 3.0
	m.grow_rate = 10.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 3.0
	def.on_hit.append(d)
	_add_aoe_visuals(def)
	return def

## Ember: an on_tick status that erupts a small nova on the burning target each second.
static func _ember() -> SpawnOnTickStatus:
	var s := SpawnOnTickStatus.new()
	s.element = Utility.Element.Fire
	s.duration = 3.0
	s.interval = 1.0
	s.spell = _ember_nova()
	return s

static func player_loadout() -> Array[SpellDefinition]:
	var loadout: Array[SpellDefinition] = []
	loadout.append(fire_fan())        # 1: spread of straight bolts
	loadout.append(flame_cone())      # 2: expanding cast-time cone
	loadout.append(piercing_lance())  # 3: fast piercing wedge (ice-coloured)
	loadout.append(fire_burst())      # 4: bolt that bursts into a nova (recursion)
	loadout.append(dash())            # 5: self-cast, no projectile
	loadout.append(lightning())       # 6: fast forking piercing beams
	loadout.append(earth())           # 7: slow expanding shockwave at the caster
	return loadout

## The enemy's kit — same classes as the player's, faction supplies friend/foe. Two
## slow bolts so the player-side wiring is exercised: one slows + burns, one stuns.
static func enemy_loadout() -> Array[SpellDefinition]:
	var loadout: Array[SpellDefinition] = []
	loadout.append(hex_bolt())    # damage + slow + burn
	loadout.append(shock_bolt())  # damage + brief stun
	return loadout

## Enemy: a slow purple bolt that damages, slows, and ignites the player.
static func hex_bolt() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 2.0
	def.lifetime = 4.0
	def.max_range = 800.0
	def.element = Utility.Element.Void
	var s := CircleHitShape.new()
	s.radius = 12.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 280.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 6.0
	def.on_hit.append(d)
	var slow := ApplyStatusEffect.new()
	slow.status = _slow()
	def.on_hit.append(slow)
	var burn := ApplyStatusEffect.new()
	burn.status = _burn()
	def.on_hit.append(burn)
	def.visuals.append(StreamParticleVisual.new())
	def.visuals.append(TrailVisual.new())
	return def

## Enemy: a faster bolt that briefly stuns (roots) the player on hit.
static func shock_bolt() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 3.0
	def.lifetime = 3.0
	def.max_range = 900.0
	def.element = Utility.Element.Electric
	var s := CircleHitShape.new()
	s.radius = 10.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 450.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 4.0
	def.on_hit.append(d)
	var stun := ApplyStatusEffect.new()
	stun.status = _stun()
	def.on_hit.append(stun)
	def.visuals.append(ShapeFillVisual.new())
	def.visuals.append(TrailVisual.new())
	return def

## 1 — three straight fire bolts in a fan, instant.
static func fire_fan() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 1.0
	def.lifetime = 1.5
	def.max_range = 600.0
	def.element = Utility.Element.Fire
	var e := FanPattern.new()
	e.count = 3
	e.spread_deg = 30.0
	def.emission = e
	var s := CircleHitShape.new()
	s.radius = 12.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 450.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 8.0
	def.on_hit.append(d)
	def.visuals.append(StreamParticleVisual.new()) # the flame IS the body
	def.visuals.append(TrailVisual.new())
	def.visuals.append(BurstVisual.new()) # sparks where each bolt lands
	return def

## 2 — a growing cone with a short cast; move-while-casting; hits everything in it.
static func flame_cone() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cast_time = 0.5
	def.cooldown = 3.0
	def.can_move_while_casting = true
	def.lifetime = 0.8
	def.pierce = true
	def.element = Utility.Element.Fire
	var s := ConeHitShape.new()
	s.width = 120.0
	s.length = 40.0
	def.shape = s
	var m := ExpandMovement.new()
	m.max_scale = 4.0
	m.grow_rate = 5.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 5.0
	def.on_hit.append(d)
	var burn := ApplyStatusEffect.new()
	burn.status = _burn() # the cone sets everything it sweeps on fire
	def.on_hit.append(burn)
	_add_aoe_visuals(def)
	return def

## 3 — fast triangular lance that pierces through enemies. Ice-coloured, fill only.
static func piercing_lance() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 0.5
	def.lifetime = 2.0
	def.max_range = 800.0
	def.pierce = true
	def.element = Utility.Element.Ice
	var s := TriangleHitShape.new()
	s.width = 24.0
	s.length = 40.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 700.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 6.0
	def.on_hit.append(d)
	var frost := ApplyStatusEffect.new()
	frost.status = _frost() # each pierce leaves an independent frostbite stack
	def.on_hit.append(frost)
	_add_visuals(def) # outline + shape-filling flame → the wedge reads
	def.visuals.append(TrailVisual.new())
	def.visuals.append(BurstVisual.new()) # spark on each pierced enemy
	return def

## 4 — a bolt that, on expiry, casts a second spell (an expanding nova). Recursion.
static func fire_burst() -> SpellDefinition:
	var nova := SpellDefinition.new()
	nova.lifetime = 0.5
	nova.pierce = true
	nova.element = Utility.Element.Fire
	var ns := CircleHitShape.new()
	ns.radius = 10.0
	nova.shape = ns
	var nm := ExpandMovement.new()
	nm.max_scale = 6.0
	nm.grow_rate = 12.0
	nova.movement = nm
	var nd := DamageEffect.new()
	nd.base_damage = 10.0
	nova.on_hit.append(nd)
	var nburn := ApplyStatusEffect.new()
	nburn.status = _burn() # bolt → nova → burn: recursion and status compose
	nova.on_hit.append(nburn)
	var nember := ApplyStatusEffect.new()
	nember.status = _ember() # …and the burn periodically re-erupts (SpawnOnTick)
	nova.on_hit.append(nember)
	_add_aoe_visuals(nova)

	var def := SpellDefinition.new()
	def.cooldown = 2.0
	def.lifetime = 0.7
	def.max_range = 300.0
	def.element = Utility.Element.Fire
	var s := CircleHitShape.new()
	s.radius = 8.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 350.0
	def.movement = m
	var spawn := SpawnSpellEffect.new()
	spawn.spell = nova
	spawn.inherit_direction = false
	def.on_expire.append(spawn)
	def.visuals.append(StreamParticleVisual.new())
	def.visuals.append(TrailVisual.new())
	return def

## 6 — lightning: three thin beams that pierce everything, very fast, instant. Crisp
## (no fluid flame) so it reads electric, not fiery.
static func lightning() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 0.7
	def.lifetime = 0.6
	def.max_range = 900.0
	def.pierce = true
	def.element = Utility.Element.Electric
	var e := FanPattern.new()
	e.count = 3
	e.spread_deg = 18.0
	def.emission = e
	var s := RectangleHitShape.new()
	s.width = 10.0
	s.length = 70.0
	def.shape = s
	var m := StraightMovement.new()
	m.speed = 1100.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 5.0
	def.on_hit.append(d)
	var stun := ApplyStatusEffect.new()
	stun.status = _stun() # a shock briefly roots whatever the beam strikes
	def.on_hit.append(stun)
	def.visuals.append(ShapeFillVisual.new())      # bright beam core
	def.visuals.append(StreamParticleVisual.new()) # sharp, fast, erratic sparks (Electric slider preset)
	def.visuals.append(TrailVisual.new())
	def.visuals.append(BurstVisual.new())          # spark on each pierced enemy
	return def

## 7 — earth: a heavy shockwave that expands outward from the caster (self-centered
## AoE, not thrown). Slow, high damage, short cast time.
static func earth() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cast_time = 0.4
	def.cooldown = 4.0
	def.lifetime = 0.7
	def.pierce = true
	def.element = Utility.Element.Earth
	var s := CircleHitShape.new()
	s.radius = 20.0
	def.shape = s
	var m := ExpandMovement.new()
	m.max_scale = 8.0
	m.grow_rate = 10.0
	def.movement = m
	var d := DamageEffect.new()
	d.base_damage = 12.0
	def.on_hit.append(d)
	var slow := ApplyStatusEffect.new()
	slow.status = _slow() # the shockwave leaves the ground heavy underfoot
	def.on_hit.append(slow)
	_add_aoe_visuals(def) # floor telegraph + expanding shockwave ring
	return def

## 5 — dash: no hitbox, an on_cast effect that moves the caster.
static func dash() -> SpellDefinition:
	var def := SpellDefinition.new()
	def.cooldown = 1.0
	var d := DashEffect.new()
	d.speed = 1500.0
	d.duration = 0.2
	def.on_cast.append(d)
	return def
