extends TDPanel
class_name TD4Notes

const NOTES_DIRECTORY_PATH := TD4.PLUGIN_PATH + "notes/"
const SUPPORTED_EXT := ["txt", "md", "cfg", "ini", "log", "json", "yml", "yaml", "toml"]

#const TAB_ICON: Texture2D = preload(PLUGIN_PATH + "icons/text_file.svg")

var _save_path: String

var _btn_save: Button
var _label_unsaved: Label
var _text: TextEdit
var _files: PackedStringArray
var _files_tab: TabBar
var delete_confirm_dialog: ConfirmationDialog

var _new_node: Control


func get_all_files(path: String, file_ext: PackedStringArray = []) -> PackedStringArray:
	var dir = DirAccess.open(path)
	
	if(dir == null):
		return []
	
	var file_names = dir.get_files()
	
	var result = PackedStringArray()
	
	for f in file_names:
		if(file_ext.size() == 0 || file_ext.has(f.get_extension())):
			result.append(f)
	
	return result


func _tab_changed(tab_index: int) -> void:
	if(tab_index < 0 || tab_index >= _files.size()):
		_reload_tabs()
		return
	
	var file_name = _files[tab_index]
	var path: String = NOTES_DIRECTORY_PATH + file_name;
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		_save_path = path
		_text.text = file.get_as_text()
		_text.clear_undo_history()
		_change_save_status(false)
	else:
		_reload_tabs()


func _open_new() -> void:
	if(_new_node.visible == true):
		return
	
	_new_node.visible = true


func _close_new() -> void:
	if(_new_node.visible == false):
		return
	
	var input = _new_node.get_node("file_name") as LineEdit
	input.clear()
	_new_node.visible = false


func _reload_tabs() -> void:
	_files = get_all_files(NOTES_DIRECTORY_PATH, SUPPORTED_EXT)
	_files_tab.clear_tabs()
	for f in _files:
		_files_tab.add_tab(f.get_basename())#, TAB_ICON)
	
	_close_new()
	_files_tab.current_tab = 0


func _btn_reload_click() -> void:
	_tab_changed(_files_tab.current_tab)


func _change_save_status(needs_save: bool) -> void:
	_btn_save.disabled = !needs_save
	_label_unsaved.visible = needs_save


func _btn_save_click() -> void:
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	file.store_string(_text.text)
	file.close()
	_change_save_status(false)


func _new_file() -> void:
	var input = _new_node.get_node("file_name") as LineEdit
	var ext = SUPPORTED_EXT[(_new_node.get_node("file_ext") as OptionButton).selected]
	var file_name: String = input.text + "." + ext
	_save_path = NOTES_DIRECTORY_PATH + file_name;
	
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	file.store_string("")
	file.close()
	_change_save_status(false)
	
	_reload_tabs()
	_files_tab.current_tab = _files.find(file_name)


func _notes_option_selected(option_index: int) -> void:
	match option_index:
		0:
			_reload_tabs()
		1:
			_open_new()


func _delete_file() -> void:
	var dir = DirAccess.open(NOTES_DIRECTORY_PATH)
	dir.remove(_files[_files_tab.current_tab])
	_reload_tabs()


func _show_delete_confirm(file_index: int) -> void:
	if(file_index < 0 || file_index >= _files.size()):
		_reload_tabs()
		return
	
	var delete_confirm_dialog = _dock.get_node("dialog_confirm_delete") as ConfirmationDialog
	delete_confirm_dialog.dialog_text = "Are you sure you want to delete the file '%s'?" % _files[file_index]
	delete_confirm_dialog.show()


func apply_config(config_file: ConfigFile) -> void:
	if(_dock == null):
		return
	
	_text.wrap_mode = 1 if config_file.get_value("general", T4DConfigKeys.WRAP_TEXT, false) == true else 0
	
	var conns := _files_tab.get_signal_connection_list("tab_changed")
	for cur_conn in conns:
		_files_tab.disconnect(cur_conn.signal.get_name(), cur_conn.callable)
	
	if(config_file.get_value("general", T4DConfigKeys.AUTO_SAVE, false)):
		_files_tab.connect("tab_changed", func(tab_index): _btn_save_click())
		
	_files_tab.connect("tab_changed", _tab_changed)

func init(dock: Control) -> void:
	super.init(dock)
	
	# tabs
	_files_tab = dock.get_node("tabs/files") as TabBar
	_files_tab.connect("tab_changed", _tab_changed)
	_files_tab.connect("tab_close_pressed", _show_delete_confirm)
	var delete_confirm_dialog = dock.get_node("dialog_confirm_delete") as ConfirmationDialog
	delete_confirm_dialog.connect("confirmed", _delete_file)
	
	# options
	var notes_options = dock.get_node("tabs/options") as MenuButton
	notes_options.get_popup().connect("index_pressed", _notes_option_selected)
	_new_node = dock.get_node("h_new") as Control
	_new_node.get_node("btn_new").connect("pressed", _new_file)
	_new_node.get_node("btn_close").connect("pressed", _close_new)
	
	# edit
	var h_edit = dock.get_node("h_edit") as HBoxContainer
	_label_unsaved = h_edit.get_node("label_unsaved") as Label
	_btn_save = h_edit.get_node("btn_save") as Button
	_btn_save.connect("pressed", _btn_save_click)
	var btn_reload = h_edit.get_node("btn_reload") as Button
	btn_reload.connect("pressed", _btn_reload_click)
	_text = dock.get_node("text_edit") as  TextEdit
	_text.connect("text_changed", func(): _change_save_status(true))
	
	_reload_tabs()
