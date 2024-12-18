extends Node

signal start_battle

signal battle_started
signal battle_ended

signal planning_phase_started
signal execution_phase_started

signal UI_move_added(move: MoveResource)

enum PHASES{
	PLANNING,
	EXECUTION
}

var battle_active: bool = false
var current_phase: PHASES
var current_enemy = null
var execution_timer: Timer

var timeline_length: float = 1.0:
	set(new_timeline_length):
		timeline_length = new_timeline_length
		num_steps = timeline_length / time_step
var filled_duration: float = 1.0
var time_step: float = 0.025:
	set(new_time_step):
		time_step = new_time_step
		num_steps = timeline_length / time_step
var num_steps: int = timeline_length / time_step
var queued_player_moves: Dictionary = {}
var queued_enemy_moves: Dictionary = {}

var player: BattleActor = preload("res://resources/battle_actor/test_player.tres")

func _ready() -> void:
	start_battle.connect(start_new_battle)
	planning_phase_started.connect(start_planning_phase)
	await get_tree().create_timer(1.0).timeout
	start_battle.emit()

func start_new_battle() -> void:
	battle_active = true
	battle_started.emit()
	
func start_planning_phase() -> void:
	current_phase = PHASES.PLANNING
	queued_player_moves = {}
	queued_enemy_moves = {}

func add_move(move: MoveResource, is_player: bool, segment_start: int) -> void:
	filled_duration -= move.duration
	if is_player:
		queued_player_moves[segment_start] = move
	else:
		queued_enemy_moves[segment_start] = move

func remove_move(move: MoveResource, is_player: bool, segment_start: int, segment_end: int) -> void:
	filled_duration += move.duration
	if is_player:
		for i in range(segment_start, segment_end):
			MoveTimeline.occupied_player_segments[i] = false
		queued_player_moves.erase(segment_start)
	else:
		for i in range(segment_start, segment_end):
			MoveTimeline.occupied_enemy_segments[i] = false
		queued_enemy_moves.erase(segment_start)

func execute_queue() -> void:
	for i in range(num_steps):
		await get_tree().create_timer(time_step).timeout
