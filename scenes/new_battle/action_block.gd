class_name ActionBlock
extends Control

signal delete_pressed(this: ActionBlock)

@export var action: MoveResource:
	set = _set_action

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	size_flags_stretch_ratio = action.length
	self.text = action.name

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = Label.new()
	preview.text = action.name
	preview.z_index = 60
	set_drag_preview(preview)
	mouse_filter = MOUSE_FILTER_IGNORE
	
	return ActionDragData.new(self, action, preview)
	
func _set_action(_action: MoveResource) -> void:
	action = _action
	$NameLabel.text = _action.name
	$HBoxContainer/Windup.size_flags_stretch_ratio = _action.windup
	$HBoxContainer/Active.size_flags_stretch_ratio = _action.active
	$HBoxContainer/Recovery.size_flags_stretch_ratio = _action.recovery
