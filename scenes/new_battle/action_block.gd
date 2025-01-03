class_name ActionBlock
extends Control

signal delete_pressed(this: ActionBlock)

@export var action: MoveResource:
	set = _set_action

var frame_data_display_scene := preload("res://scenes/new_battle/frame_data_display.tscn")
var is_obscured: bool = false: set = _obscured_changed

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
	var temp_action = action
	while temp_action != null:
		var frame_data_display = frame_data_display_scene.instantiate()
		frame_data_display.find_child("Windup").size_flags_stretch_ratio = temp_action.windup
		frame_data_display.find_child("Active").size_flags_stretch_ratio = temp_action.active
		frame_data_display.find_child("Recovery").size_flags_stretch_ratio = temp_action.recovery
		$HBoxContainer.add_child(frame_data_display)
		temp_action = temp_action.followup_attack

func _obscured_changed(new_is_obscured: bool) -> void:
	is_obscured = new_is_obscured
	if is_obscured:
		$ObscurationRect.show()
	else:
		$ObscurationRect.hide()
