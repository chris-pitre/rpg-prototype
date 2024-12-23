class_name ActionDragData

signal drag_completed(data: BattleAction)

var source: Control
var destination: Control
var action: BattleAction
var preview: Control

func _init(_source: Control, _action: BattleAction, _preview: Control) -> void:
	self.source = _source
	self.action = _action
	self.preview = _preview
	self.preview.tree_exiting.connect(_on_tree_exiting)

func _on_tree_exiting()->void:
	source.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_completed.emit(self)
