extends Control

signal moved_in_parent(control)

var reference_to: Control setget set_reference_to, get_reference_to

var _reference_to: Control = null
var _parented = false

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	connect("item_rect_changed", self, "_on_rect_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and _reference_to:
		_reference_to.visible = visible
	elif what == NOTIFICATION_PARENTED:
		_parented = true
	elif what == NOTIFICATION_UNPARENTED:
		_parented = false
	elif what == NOTIFICATION_MOVED_IN_PARENT and _parented:
		emit_signal("moved_in_parent", self)


func set_reference_to(control: Control) -> void:
	if _reference_to != control:
		if _reference_to:
			_reference_to.disconnect("renamed", self, "_on_reference_to_renamed")
		_reference_to = control
		_reference_to.connect("renamed", self, "_on_reference_to_renamed")
		_reference_to.visible = visible
		_reposition_reference()


func get_reference_to() -> Control:
	return _reference_to


func _on_rect_changed() -> void:
	if _reference_to:
		_reposition_reference()


func _reposition_reference() -> void:
	var container = get_parent_control()
	_reference_to.rect_global_position = container.rect_global_position + rect_position
	_reference_to.rect_size = rect_size


func _on_reference_to_renamed() -> void:
	name = _reference_to.name