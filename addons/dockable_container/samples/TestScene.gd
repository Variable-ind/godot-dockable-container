extends VBoxContainer

const SAVED_LAYOUT_PATH = "user://layout.tres"

onready var _container = $DockableContainer


func _ready() -> void:
	if not OS.is_userfs_persistent():
		$HBoxContainer/SaveLayoutButton.visible = false
		$HBoxContainer/LoadLayoutButton.visible = false


func _on_add_pressed() -> void:
	var control = ColorRect.new()
	control.color = Color(randf(), randf(), randf())
	control.name = "Control"
	_container.add_child(control, true)
	_container.call_deferred("set_control_as_current_tab", control)


func _on_save_pressed() -> void:
	if ResourceSaver.save(SAVED_LAYOUT_PATH, _container.split_tree_root_node) != OK:
		print("ERROR")


func _on_load_pressed() -> void:
	var res = load(SAVED_LAYOUT_PATH)
	if res:
		_container.split_tree_root_node = res
	else:
		print("Error")
