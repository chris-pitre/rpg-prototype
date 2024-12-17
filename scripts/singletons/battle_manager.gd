extends Node

signal battle_start()
signal battle_end()

signal planning_phase()
signal execution_phase()

signal UI_move_added(move: MoveResource)

enum PHASES{
	PLANNING,
	EXECUTION
}

var battle_active: bool = false
var current_phase: PHASES
var current_enemy = null
var execution_timer: Timer

var timeline_length: float = 1.0
var filled_duration: float = 1.0
var occupied_segments: Array[bool] = []

func _ready():
	current_phase = PHASES.PLANNING

func add_move(move):
	filled_duration -= move.duration

func remove_move(move, segment_start, segment_end):
	filled_duration += move.duration
	for i in range(segment_start, segment_end):
		occupied_segments[i] = false
