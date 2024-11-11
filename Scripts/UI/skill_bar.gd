class_name SkillBar extends HBoxContainer


@onready var spell_button_1: TextureButton = $SpellButton1
@onready var spell_button_2: TextureButton = $SpellButton2
@onready var spell_button_3: TextureButton = $SpellButton3
@onready var spell_button_4: TextureButton = $SpellButton4
@onready var spell_button_5: TextureButton = $SpellButton5

var slots: Array

func _ready() -> void:
	slots = get_children()
	for i in get_child_count():
		slots[i].change_input = str(i+1)
