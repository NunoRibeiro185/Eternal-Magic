class_name SpellEffect extends Resource

## Base for anything a spell DOES when it resolves. Override apply(). Effects are
## composed as a list on a SpellDefinition (on_hit / on_expire), so new mechanics
## are new subclasses — never a new branch in a central switch.

## Called on resolution. `hit.target` is the thing struck (null for on-expire).
func apply(_hit: HitInfo) -> void:
	pass
