class_name MoveTimeline extends Control

@onready var step_size: float = size[0] / BattleManager.num_steps

var is_player: bool = true

static var occupied_player_segments: Array[bool] = []
static var occupied_enemy_segments: Array[bool] = []

func _ready() -> void:
	occupied_player_segments = []
	occupied_enemy_segments = []
	for i in range(BattleManager.num_steps + 1):
		occupied_player_segments.append(false)
		occupied_enemy_segments.append(false)
	
func _process(delta: float) -> void:
	step_size = size[0] / BattleManager.num_steps

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
		if is_player:
			occupied_player_segments[i] = true
		else:
			occupied_enemy_segments[i] = true
	return true

func deoccupy_segments(segment_start: int, segment_end: int) -> bool:
	if not check_segments(segment_start, segment_end):
		return false
	for i in range(segment_start, segment_end):
		if is_player:
			occupied_player_segments[i] = false
		else:
			occupied_enemy_segments[i] = true
	return true

func check_segments(segment_start: int, segment_end: int) -> bool:
	if segment_end > BattleManager.num_steps:
		return false
	for i in range(segment_start, segment_end + 1):
		if is_player and occupied_player_segments[i]:
			return false
		elif not is_player and occupied_enemy_segments[i]:
			return false
	return true

func clear_segments() -> void:
	if is_player:
		occupied_player_segments = []
		for i in range(BattleManager.num_steps + 1):
			occupied_player_segments.append(false)
	else:
		occupied_enemy_segments = []
		for i in range(BattleManager.num_steps + 1):
			occupied_enemy_segments.append(false)
