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

func _ready():
	current_phase = PHASES.PLANNING

func move_added(move):
	filled_duration -= move.duration

func move_removed(move):
	filled_duration += move.duration
