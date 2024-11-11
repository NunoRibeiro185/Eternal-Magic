extends TextureButton

@onready var cooldown: TextureProgressBar = $Cooldown
@onready var input: Label = $Input
@onready var time: Label = $Time
@export var timer: Timer

func _ready() -> void:
	set_process(true)

var change_input = "":
	set(value):
		change_input = value
		var input_key = shortcut.events[0] as InputEventAction
		input.text = Utility.get_simplified_input_name(input_key.as_text())
		shortcut.events = [input_key]

func _process(delta: float) -> void:
	cooldown.max_value = timer.wait_time
	time.text = "%3.2f" % timer.time_left
	cooldown.value = timer.time_left
	
	
