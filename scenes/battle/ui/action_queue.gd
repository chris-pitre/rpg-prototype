extends NinePatchRect

@onready var move_drop_template = preload("res://scenes/battle/ui/move_drop.tscn")
@onready var queue_loc = $MarginContainer/MoveTimeline

func _ready() -> void:
	BattleManager.connect("UI_move_added", _add_move)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is MoveResource and data != null and BattleManager.filled_duration >= data.duration
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	_add_move(at_position, data)
		
func _add_move(at_position: Vector2, data: MoveResource) -> void:
	var segment_start = queue_loc.get_segment_num(at_position[0])
	var segment_end = queue_loc.get_end_segment(segment_start, data.duration)
	if not queue_loc.check_segments(segment_start, segment_end):
		return
	BattleManager.add_move(data)
	var move_drop = move_drop_template.instantiate()
	move_drop.move_resource = data
	move_drop.set_h_size_flags(0)
	move_drop.custom_minimum_size = Vector2(data.duration * queue_loc.size[0], 0)
	move_drop.is_queued = true
	move_drop.segment_start = segment_start
	move_drop.segment_end = segment_end
	queue_loc.add_child(move_drop)
	var x_pos = queue_loc.get_x_pos(segment_start)
	move_drop.position = Vector2(x_pos, 0)
	queue_loc.occupy_segments(segment_start, segment_end)
	
	
