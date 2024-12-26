class_name ActionBlock
extends Control

signal delete_pressed(this: ActionBlock)

@export var action: BattleAction:
	set = _set_action

func _ready() -> void:
	size_flags_stretch_ratio = action.length

func _get_drag_data(at_position: Vector2) -> Variant:
	mouse_filter = MOUSE_FILTER_IGNORE
	var preview = Label.new()
	preview.text = action.name
	set_drag_preview(preview)
	
	return ActionDragData.new(self, action, preview)

func _set_action(_action: BattleAction) -> void:
	action = _action
	$NameLabel.text = _action.name
	$HBoxContainer/Windup.size_flags_stretch_ratio = _action.windup
	$HBoxContainer/Active.size_flags_stretch_ratio = _action.active
	$HBoxContainer/Recovery.size_flags_stretch_ratio = _action.recovery
