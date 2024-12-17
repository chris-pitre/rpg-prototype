@tool
class_name MoveDragAndDrop extends Control

@onready var label = $MarginContainer/Label
var label_text: String = "<null>"
var is_queued: bool = false

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
			BattleManager.move_removed(move_resource)
			queue_free()
		elif not is_queued and BattleManager.filled_duration >= move_resource.duration:
			BattleManager.UI_move_added.emit(move_resource)
		
func _get_drag_data(at_position: Vector2) -> Variant:
	if Engine.is_editor_hint() or is_queued:
		return
	var icon = self.duplicate()
	var preview = Control.new()
	preview.add_child(icon)
	preview.z_index = 60
	set_drag_preview(preview)
	return move_resource
