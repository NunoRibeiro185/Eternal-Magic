class_name HitInfo extends RefCounted

## The packet an Effect receives when a spell resolves. Carries attribution
## (source/faction) and scaling (stats) so effects never reach back into the
## caster. A null `target` means a non-contact resolution (on-cast / on-expire).

var source: Node2D      ## who cast the spell (for kills, aggro, score)
var faction: int
var stats: StatBlock
var target: Node2D       ## what was hit (null for on-expire / on-cast effects)
var spell: RuntimeSpell  ## the live spell, if any (null for on-cast effects)
var context: CastContext ## the originating cast — lets effects reach origin/aim when there is no spell
