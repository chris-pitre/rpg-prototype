class_name ActionQueue extends HBoxContainer

@export var is_player: bool = true

@onready var move_drop_template = preload("res://scenes/battle/move_drop.tscn")
@onready var move_timeline = $MarginContainer/MoveTimeline

func _ready() -> void:
	if is_player:
		BattleManager.connect("UI_move_added", _add_end_move)
	move_timeline.is_player = is_player

func _physics_process(delta: float) -> void:
	texture.width = (get_viewport_rect().size.x - 20) / BattleManager.num_steps

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return is_player and data is MoveResource and data != null and BattleManager.filled_duration >= data.duration
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	_add_move(at_position, data)
		
func _add_move(at_position: Vector2, data: MoveResource) -> bool:
	var segment_start = move_timeline.get_segment_num(at_position[0])
	var segment_end = move_timeline.get_end_segment(segment_start, data.duration)
	if not move_timeline.check_segments(segment_start - 1, segment_end):
		return false
	BattleManager.add_move(data, true, segment_start)
	var move_drop = move_drop_template.instantiate()
	move_drop.move_resource = data
	move_drop.set_h_size_flags(0)
	move_drop.custom_minimum_size = Vector2((data.duration / BattleManager.timeline_length) * move_timeline.size[0], 0)
	move_drop.is_queued = true
	move_drop.segment_start = segment_start
	move_drop.segment_end = segment_end
	move_timeline.add_child(move_drop)
	var x_pos = move_timeline.get_x_pos(segment_start)
	move_drop.position = Vector2(x_pos, 0)
	move_timeline.occupy_segments(segment_start, segment_end)
	return true

func add_move_segment(segment: int, data: MoveResource) -> void:
	BattleManager.add_move(data, false, segment)
	var segment_end = move_timeline.get_end_segment(segment, data.duration)
	var move_drop = move_drop_template.instantiate()
	move_drop.move_resource = data
	move_drop.set_h_size_flags(0)
	move_drop.custom_minimum_size = Vector2((data.duration / BattleManager.timeline_length) * move_timeline.size[0], 0)
	#node.custom_minimum_size = Vector2((node.move_resource.duration / BattleManager.timeline_length) * size.x, 0)
	move_drop.is_queued = true
	move_drop.segment_start = segment
	move_drop.segment_end = segment_end
	move_timeline.add_child(move_drop)
	var x_pos = move_timeline.get_x_pos(segment)
	move_drop.position = Vector2(x_pos, 0)
	move_timeline.occupy_segments(segment, segment_end)

func _add_end_move(data: MoveResource) -> void:
	if _add_move(Vector2(0, 0), data):
		return
	for i in range(1, BattleManager.num_steps):
		if _add_move(Vector2(move_timeline.step_size * i - (move_timeline.step_size / 2), 0), data):
			break
	
func clear_queue() -> void:
	for i in move_timeline.get_children():
		i.queue_free()
	move_timeline.clear_segments()
