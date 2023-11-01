extends TDPanel
class_name TD4Settings

signal on_config_changed(new_config_file: ConfigFile)

const CONFIG_DIRECTORY_PATH := TD4.PLUGIN_PATH + "config/"
const CONFIG_PATH := CONFIG_DIRECTORY_PATH + "config.ini"

var _toggle_auto_save: CheckButton
var _toggle_wrap_text: CheckButton

var _config_file_default: ConfigFile
var config_file: ConfigFile


func save_config() -> void:
	config_file.save(CONFIG_PATH)
	on_config_changed.emit(config_file)


func _toggled_auto_save() -> void:
	config_file.set_value("general", "auto_save", _toggle_auto_save.button_pressed)
	save_config()


func _toggled_wrap_text() -> void:
	config_file.set_value("general", "wrap_text", _toggle_auto_save.button_pressed)
	save_config()


func init(dock: Control) -> void:
	super.init(dock)
	
	_toggle_auto_save = dock.get_node("general/v_box_container/auto_save") as CheckButton
	_toggle_auto_save.connect("pressed", _toggled_auto_save)
	_toggle_wrap_text = dock.get_node("general/v_box_container/wrap_text") as CheckButton
	_toggle_wrap_text.connect("pressed", _toggled_wrap_text)
	
	config_file = ConfigFile.new()
	config_file.load(CONFIG_PATH)
	_toggle_auto_save.button_pressed = config_file.get_value("general", T4DConfigKeys.AUTO_SAVE, false)
	_toggle_wrap_text.button_pressed = config_file.get_value("general", T4DConfigKeys.WRAP_TEXT, false)
