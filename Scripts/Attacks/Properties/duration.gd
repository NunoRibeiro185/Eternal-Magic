class_name Duration extends Node

var timer := Timer.new()
var spell : Spell

func _init(s) -> void:
	spell = s
	add_child(timer)
	timer.wait_time = spell.ar.duration
	timer.connect("timeout", _on_timer_timeout)
	
func _ready() -> void:
	timer.start()
	 
func _on_timer_timeout() -> void:
	spell.queue_free()
