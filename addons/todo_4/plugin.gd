@tool
extends EditorPlugin
class_name TD4

const PLUGIN_PATH := "res://addons/todo_4/"
const SRC_DIRECTORY_PATH := TD4.PLUGIN_PATH + "src/"

var _dock: Control
var _select_panel: MenuButton
var _current_panel_index := -1

var _panels: Array[TDPanel] = []


func _enter_tree() -> void:
	_dock = preload(PLUGIN_PATH + "notes.tscn").instantiate() as Control
	add_control_to_dock(DOCK_SLOT_RIGHT_BR, _dock)
	
	var settings = preload(SRC_DIRECTORY_PATH + "settings.gd").new() as TD4Settings
	settings.init(_dock.get_node("settings"))
	
	
	var notes = preload(SRC_DIRECTORY_PATH + "notes.gd").new() as TD4Notes
	notes.init(_dock.get_node("notes"))
	notes.apply_config(settings.config_file)
	
	var on_config_changed = func(new_config_file: ConfigFile): notes.apply_config(new_config_file)
	settings.connect("on_config_changed", on_config_changed)
	
	
	_panels.append(notes)
	_panels.append(settings)
	
	_select_panel = _dock.get_node("select_panel") as MenuButton
	_select_panel.get_popup().connect("index_pressed", _change_panel)
	
	_change_panel(0)


func _change_panel(panel_index: int) -> void:
	if(panel_index < 0 ||
	panel_index >= _panels.size() ||
	panel_index == _current_panel_index):
		return
	
	_panels[_current_panel_index].hide()
	_panels[panel_index].show()
	
	_select_panel.icon = _select_panel.get_popup().get_item_icon(panel_index)
	
	_current_panel_index = panel_index


func _exit_tree() -> void:
	remove_control_from_docks(_dock)
	_dock.free()
