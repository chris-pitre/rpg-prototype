class_name ActionBlock
extends Control

signal delete_pressed(this: ActionBlock)

@export var action: BattleAction

func _ready() -> void:
	size_flags_stretch_ratio = action.length

func _get_drag_data(at_position: Vector2) -> Variant:
	mouse_filter = MOUSE_FILTER_IGNORE
	var preview = Label.new()
	preview.text = action.name
	set_drag_preview(preview)
	
	return ActionDragData.new(self, action, preview)
