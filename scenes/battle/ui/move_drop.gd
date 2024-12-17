@tool
class_name MoveDragAndDrop extends Control

@onready var label = $MarginContainer/Label
var label_text: String = "<null>"
var is_queued: bool = false
var segment_start: int
var segment_end: int
var is_dragged: bool = false

@export var move_resource: MoveResource:
	set(new_move):
		if new_move != null:
			move_resource = new_move
			label_text = move_resource.move_name
		else:
			move_resource = null
			
func _ready() -> void:
	label.text = label_text
			
func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if is_queued:
			BattleManager.remove_move(move_resource, segment_start, segment_end)
			queue_free()
		elif not is_queued and BattleManager.filled_duration >= move_resource.duration:
			BattleManager.UI_move_added.emit(move_resource)
			
		
func _get_drag_data(at_position: Vector2) -> Variant:
	if Engine.is_editor_hint():
		return null
	is_dragged = true
	if is_queued:
		BattleManager.remove_move(move_resource, segment_start, segment_end)
		var icon = self.duplicate()
		var preview = Control.new()
		preview.add_child(icon)
		preview.z_index = 60
		icon.position = Vector2(0, 0)
		set_drag_preview(preview)
		modulate.a = 0.2
		return move_resource
	else:
		var icon = self.duplicate()
		var preview = Control.new()
		icon.set_h_size_flags(0)
		icon.custom_minimum_size = Vector2(move_resource.duration * 1153, 0)
		preview.add_child(icon)
		preview.z_index = 60
		set_drag_preview(preview)
		return move_resource

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			if is_dragged and is_queued:
				queue_free()
