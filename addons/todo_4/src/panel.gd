extends Node
class_name TDPanel


var _dock: Control


func init(dock: Control) -> void:
	_dock = dock


func show() -> void:
	if(_dock == null ||
	_dock.visible):
		return
	
	_dock.visible = true


func hide() -> void:
	if(_dock == null ||
	!_dock.visible):
		return
	
	_dock.visible = false
