class_name MoveTimeline extends Control

@onready var num_steps: int = BattleManager.timeline_length / time_granularity
@onready var step_size: float = size[0] / num_steps
@onready var occupied_segments: Dictionary

@export var time_granularity: float = 0.025:
	set(new_time):
		time_granularity = new_time
		num_steps = BattleManager.timeline_length / time_granularity
		step_size = size[0] / num_steps

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	num_steps = BattleManager.timeline_length / time_granularity
	step_size = size[0] / num_steps
	print(num_steps)
	print(step_size)
	occupy_segments(0, 0.5)

func get_segment_num(x_position: int) -> int:
	return x_position / step_size

func get_x_pos(segment_num: int) -> int:
	return segment_num * step_size

func occupy_segments(segment_start: int, duration: float) -> bool:
	var segment_end = get_segment_num((segment_start * step_size) + (BattleManager.timeline_length * duration * size[0])) - 1
	for i in range(segment_start, segment_end):
		if occupied_segments[i] == true:
			return false
	for i in range(segment_start, segment_end):
		occupied_segments[i] = true
	return true

func deoccupy_segments(segment_start: int, duration: float) -> bool:
	var segment_end = get_segment_num((segment_start * step_size) + (BattleManager.timeline_length * duration * size[0])) - 1
	for i in range(segment_start, segment_end):
		occupied_segments[i] = false
	return true
