class_name ActionBlock
extends Control

signal delete_pressed(this: ActionBlock)

@export var action: MoveResource

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	size_flags_stretch_ratio = action.length
	self.text = action.name

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = Label.new()
	preview.text = action.name
	set_drag_preview(preview)
	
	return ActionDragData.new(self, action, preview)

func _on_button_down() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

func _on_button_up() -> void:
	mouse_filter = MOUSE_FILTER_STOP
