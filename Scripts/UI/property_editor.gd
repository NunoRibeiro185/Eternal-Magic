class_name PropertyEditor extends VBoxContainer

## A tiny runtime inspector: given any Object, it reads the script's exported properties
## and builds a control for each, so the in-game spell editor stays in lockstep with the
## real SpellDefinition — new @export fields and new subclasses show up automatically.
## Recurses into Resource-typed fields (with a subclass picker) and Array[Resource]
## fields (add / remove / type-pick), which is what makes the effects + visuals editable.

signal changed ## emitted on ANY edit, at any depth

## The @abstract slot bases: excluded from pickers (can't be instantiated). A concrete
## base with no subclasses (e.g. ElementStyle) is NOT here, so it stays pickable.
## Keep in sync if a new abstract base is added.
const ABSTRACT := [
	"EmissionPattern", "HitShape", "SpellMovement", "SpellEffect",
	"StatusEffect", "SpellVisual", "SpellComponent",
]

var _object: Object

func edit(obj: Object) -> void:
	_object = obj
	_rebuild()

func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	if _object == null:
		return
	for prop in _object.get_property_list():
		if _is_export(prop):
			_add_property(prop)

func _is_export(prop: Dictionary) -> bool:
	var usage: int = prop["usage"]
	return (usage & PROPERTY_USAGE_EDITOR) != 0 and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0

# ---------------------------------------------------------------- dispatch

func _add_property(prop: Dictionary) -> void:
	var pname: String = prop["name"]
	var ptype: int = prop["type"]
	var hint: int = prop["hint"]
	var hint_string: String = prop["hint_string"]

	if ptype == TYPE_OBJECT:
		_add_object_prop(pname, hint_string)
	elif ptype == TYPE_ARRAY:
		_add_array_prop(pname, _array_element_base(hint_string))
	else:
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = pname.capitalize()
		label.custom_minimum_size = Vector2(130, 0)
		row.add_child(label)
		var control := _make_scalar(pname, ptype, hint, hint_string)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(control)
		add_child(row)

# ---------------------------------------------------------------- scalars

func _make_scalar(pname: String, ptype: int, hint: int, hint_string: String) -> Control:
	match ptype:
		TYPE_BOOL:
			var chk := CheckBox.new()
			chk.button_pressed = _read(pname)
			chk.toggled.connect(_on_bool.bind(pname))
			return chk
		TYPE_INT:
			if hint == PROPERTY_HINT_ENUM:
				return _make_enum(pname, hint_string)
			var spin_i := SpinBox.new()
			spin_i.rounded = true
			spin_i.step = 1
			spin_i.min_value = -100000
			spin_i.max_value = 100000
			spin_i.allow_greater = true
			spin_i.allow_lesser = true
			spin_i.value = _read(pname)
			spin_i.value_changed.connect(_on_int.bind(pname))
			return spin_i
		TYPE_FLOAT:
			var spin_f := SpinBox.new()
			spin_f.step = 0.05
			spin_f.min_value = -100000
			spin_f.max_value = 100000
			spin_f.allow_greater = true
			spin_f.allow_lesser = true
			if hint == PROPERTY_HINT_RANGE:
				_apply_range(spin_f, hint_string)
			spin_f.value = _read(pname)
			spin_f.value_changed.connect(_on_float.bind(pname))
			return spin_f
		TYPE_COLOR:
			var col := ColorPickerButton.new()
			col.color = _read(pname)
			col.custom_minimum_size = Vector2(0, 24)
			col.color_changed.connect(_on_color.bind(pname))
			return col
		TYPE_VECTOR2:
			var box := HBoxContainer.new()
			var v: Vector2 = _read(pname)
			var sx := _vec_spin(v.x)
			var sy := _vec_spin(v.y)
			box.add_child(sx)
			box.add_child(sy)
			sx.value_changed.connect(_on_vec2.bind(pname, sx, sy))
			sy.value_changed.connect(_on_vec2.bind(pname, sx, sy))
			return box
		TYPE_STRING, TYPE_STRING_NAME:
			var line := LineEdit.new()
			line.text = str(_read(pname))
			line.text_changed.connect(_on_string.bind(pname))
			return line
	var lbl := Label.new()
	lbl.text = "(unsupported)"
	lbl.modulate = Color(1, 1, 1, 0.5)
	return lbl

func _make_enum(pname: String, hint_string: String) -> OptionButton:
	var opt := OptionButton.new()
	var values := []
	var cur: int = _read(pname)
	var entries := hint_string.split(",")
	for i in entries.size():
		var entry: String = entries[i]
		var val := i
		if ":" in entry:
			var parts := entry.split(":")
			entry = parts[0]
			val = int(parts[1])
		opt.add_item(entry)
		values.append(val)
		if val == cur:
			opt.select(i)
	opt.item_selected.connect(_on_enum.bind(pname, values))
	return opt

func _vec_spin(val: float) -> SpinBox:
	var s := SpinBox.new()
	s.step = 0.5
	s.min_value = -100000
	s.max_value = 100000
	s.allow_greater = true
	s.allow_lesser = true
	s.value = val
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return s

func _apply_range(spin: SpinBox, hint_string: String) -> void:
	var parts := hint_string.split(",")
	if parts.size() >= 1 and parts[0].is_valid_float():
		spin.min_value = float(parts[0])
	if parts.size() >= 2 and parts[1].is_valid_float():
		spin.max_value = float(parts[1])
	if parts.size() >= 3 and parts[2].is_valid_float():
		spin.step = float(parts[2])

# ---------------------------------------------------------------- Resource slot

func _add_object_prop(pname: String, base: String) -> void:
	var box := VBoxContainer.new()
	var header := HBoxContainer.new()
	var label := Label.new()
	label.text = pname.capitalize()
	label.custom_minimum_size = Vector2(130, 0)
	header.add_child(label)

	var opt := OptionButton.new()
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt.add_item("<none>")
	opt.set_item_metadata(0, "")
	var options := _concrete_options(base)
	var current_cls := _class_name_of(_read(pname))
	for i in options.size():
		var o: Dictionary = options[i]
		opt.add_item(o["name"])
		opt.set_item_metadata(i + 1, o["path"])
		if o["name"] == current_cls:
			opt.select(i + 1)
	header.add_child(opt)
	box.add_child(header)

	var nested := VBoxContainer.new()
	var indent := MarginContainer.new()
	indent.add_theme_constant_override("margin_left", 18)
	indent.add_child(nested)
	box.add_child(indent)
	add_child(box)

	opt.item_selected.connect(_on_object_type.bind(pname, opt, nested))
	_populate_nested(nested, _read(pname))

func _on_object_type(idx: int, pname: String, opt: OptionButton, nested: Node) -> void:
	var path: String = opt.get_item_metadata(idx)
	var inst: Object = _instantiate(path) if path != "" else null
	_write(pname, inst)
	_populate_nested(nested, inst)

# ---------------------------------------------------------------- Array[Resource] slot

func _add_array_prop(pname: String, element_base: String) -> void:
	var box := VBoxContainer.new()
	var label := Label.new()
	label.text = pname.capitalize()
	box.add_child(label)

	var list := VBoxContainer.new()
	var indent := MarginContainer.new()
	indent.add_theme_constant_override("margin_left", 18)
	indent.add_child(list)
	box.add_child(indent)

	var add_btn := Button.new()
	add_btn.text = "+ Add"
	add_btn.pressed.connect(_on_array_add.bind(pname, element_base, list))
	box.add_child(add_btn)
	add_child(box)

	_rebuild_array(pname, element_base, list)

func _rebuild_array(pname: String, element_base: String, list: Node) -> void:
	for c in list.get_children():
		c.queue_free()
	var arr: Array = _read(pname)
	var options := _concrete_options(element_base)
	for i in arr.size():
		var elem: Object = arr[i]
		var row := HBoxContainer.new()
		var opt := OptionButton.new()
		opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cls := _class_name_of(elem)
		for j in options.size():
			var o: Dictionary = options[j]
			opt.add_item(o["name"])
			opt.set_item_metadata(j, o["path"])
			if o["name"] == cls:
				opt.select(j)
		row.add_child(opt)
		var rm := Button.new()
		rm.text = "X"
		row.add_child(rm)
		list.add_child(row)

		var nested := VBoxContainer.new()
		var indent := MarginContainer.new()
		indent.add_theme_constant_override("margin_left", 18)
		indent.add_child(nested)
		list.add_child(indent)
		_populate_nested(nested, elem)

		opt.item_selected.connect(_on_array_elem_type.bind(pname, i, opt, nested))
		rm.pressed.connect(_on_array_remove.bind(pname, i, element_base, list))

func _on_array_add(pname: String, element_base: String, list: Node) -> void:
	var options := _concrete_options(element_base)
	if options.is_empty():
		return
	var arr: Array = _read(pname)
	arr.append(_instantiate(options[0]["path"]))
	changed.emit()
	_rebuild_array(pname, element_base, list)

func _on_array_elem_type(idx: int, pname: String, elem_index: int, opt: OptionButton, nested: Node) -> void:
	var path: String = opt.get_item_metadata(idx)
	var arr: Array = _read(pname)
	arr[elem_index] = _instantiate(path)
	changed.emit()
	_populate_nested(nested, arr[elem_index])

func _on_array_remove(pname: String, elem_index: int, element_base: String, list: Node) -> void:
	var arr: Array = _read(pname)
	arr.remove_at(elem_index)
	changed.emit()
	_rebuild_array(pname, element_base, list)

# ---------------------------------------------------------------- nested editor

func _populate_nested(container: Node, inst: Object) -> void:
	for c in container.get_children():
		c.queue_free()
	if inst == null:
		return
	var sub := PropertyEditor.new()
	sub.changed.connect(_on_child_changed)
	container.add_child(sub)
	sub.edit(inst)

func _on_child_changed() -> void:
	changed.emit()

# ---------------------------------------------------------------- value setters

func _read(pname: String):
	return _object.get(pname)

func _write(pname: String, value) -> void:
	_object.set(pname, value)
	changed.emit()

func _on_bool(pressed: bool, pname: String) -> void:
	_write(pname, pressed)

func _on_int(value: float, pname: String) -> void:
	_write(pname, int(value))

func _on_float(value: float, pname: String) -> void:
	_write(pname, value)

func _on_color(value: Color, pname: String) -> void:
	_write(pname, value)

func _on_string(value: String, pname: String) -> void:
	_write(pname, value)

func _on_enum(idx: int, pname: String, values: Array) -> void:
	_write(pname, int(values[idx]))

func _on_vec2(_v: float, pname: String, sx: SpinBox, sy: SpinBox) -> void:
	_write(pname, Vector2(sx.value, sy.value))

# ---------------------------------------------------------------- reflection helpers

func _instantiate(path: String) -> Object:
	if path == "":
		return null
	var scr := load(path) as GDScript
	if scr == null:
		return null
	return scr.new()

func _class_name_of(obj: Object) -> String:
	if obj == null:
		return ""
	var scr := obj.get_script() as Script
	if scr == null:
		return obj.get_class()
	return String(scr.get_global_name())

func _array_element_base(hint_string: String) -> String:
	if hint_string == "":
		return ""
	if ":" in hint_string:
		return hint_string.get_slice(":", hint_string.get_slice_count(":") - 1)
	return hint_string

## Concrete (non-abstract) script classes that inherit from `base`. Abstract bases are
## excluded because they never appear as their own subclass, and our slot bases are the
## only abstract classes — so "everything below the base" is exactly the pickable set.
func _concrete_options(base: String) -> Array:
	var out := []
	if base == "":
		return out
	var list := ProjectSettings.get_global_class_list()
	var bmap := {}
	for e in list:
		bmap[e["class"]] = e["base"]
	for e in list:
		var cls: String = e["class"]
		if cls in ABSTRACT:
			continue
		# The base itself (if concrete, e.g. ElementStyle) plus every descendant.
		if cls == base or _inherits(cls, base, bmap):
			out.append({ "name": cls, "path": e["path"] })
	return out

func _inherits(cls: String, base: String, bmap: Dictionary) -> bool:
	var c := cls
	while bmap.has(c):
		c = String(bmap[c])
		if c == base:
			return true
	return false
