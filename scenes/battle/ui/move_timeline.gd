class_name MoveTimeline extends Control

@onready var num_steps: int = BattleManager.timeline_length / time_granularity
@onready var step_size: float = size[0] / num_steps

@export var time_granularity: float = 0.025:
	set(new_time):
		time_granularity = new_time
		num_steps = BattleManager.timeline_length / time_granularity
		step_size = size[0] / num_steps

func _ready() -> void:
	BattleManager.occupied_segments = []
	for i in range(num_steps + 1):
		BattleManager.occupied_segments.append(false)
	
func _process(delta: float) -> void:
	num_steps = (BattleManager.timeline_length / time_granularity)
	step_size = size[0] / num_steps

func get_segment_num(x_position: int) -> int:
	return x_position / step_size
	
func get_end_segment(segment_start: int, duration: float) -> int:
	return get_segment_num((segment_start * step_size) + (BattleManager.timeline_length * duration * size[0]))

func get_x_pos(segment_num: int) -> int:
	return segment_num * step_size

func occupy_segments(segment_start: int, segment_end: int) -> bool:
	if not check_segments(segment_start, segment_end):
		return false
	for i in range(segment_start, segment_end):
		BattleManager.occupied_segments[i] = true
	return true

func deoccupy_segments(segment_start: int, segment_end: int) -> bool:
	if not check_segments(segment_start, segment_end):
		return false
	for i in range(segment_start, segment_end):
		BattleManager.occupied_segments[i] = false
	return true

func check_segments(segment_start: int, segment_end: int) -> bool:
	if segment_end > num_steps:
		return false
	for i in range(segment_start, segment_end + 1):
		if BattleManager.occupied_segments[i]:
			return false
	return true
