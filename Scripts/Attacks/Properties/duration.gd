class_name Duration extends Node

var timer := Timer.new()
var projectile : Projectile

func _init(p) -> void:
	projectile = p 
	add_child(timer)
	timer.wait_time = projectile.ar.duration
	timer.connect("timeout", _on_timer_timeout)
	
func _ready() -> void:
	timer.start()
	 
func _on_timer_timeout() -> void:
	projectile.queue_free()
