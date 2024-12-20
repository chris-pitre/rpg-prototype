extends Node

signal start_battle(encounter: Encounter)

signal battle_started
signal battle_ended(encounter: Encounter, player_lost: bool)

signal planning_phase_started
signal execution_phase_started

signal UI_move_added(move: MoveResource)

signal player_animation(animation_name: String, duration: float)
signal enemy_animation(animation_name: String, duration: float)

signal player_stats_updated(new_value: int)
signal enemy_stats_updated(new_value: int)

enum PHASES{
	PLANNING,
	EXECUTION
}

var battle_active: bool = false
var current_encounter: Encounter
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

var player: BattleActorStats = preload("res://resources/battle_actor/test_player.tres")
var enemy: BattleActorStats

func _ready() -> void:
	start_battle.connect(start_new_battle)

func start_new_battle(encounter: Encounter) -> void:
	current_encounter = encounter
	enemy = encounter.enemy.duplicate()
	battle_active = true
	player_stats_updated.emit(player.hp)
	enemy_stats_updated.emit(enemy.hp)
	await battle_started
	start_planning_phase()
	
func start_planning_phase() -> void:
	filled_duration = timeline_length
	current_phase = PHASES.PLANNING
	planning_phase_started.emit()
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

func start_execution_phase() -> void:
	current_phase = PHASES.EXECUTION
	execution_phase_started.emit()
	for i in range(num_steps):
		if player.hp <= 0:
			battle_ended.emit(current_encounter, false)
			break
		elif enemy.hp <= 0:
			battle_ended.emit(current_encounter, true)
			break
		var player_move = queued_player_moves.get(i)
		var enemy_move = queued_enemy_moves.get(i)
		if player_move != null:
			player_animation.emit(player_move.animation_name, player_move.duration)
		if enemy_move != null:
			enemy_animation.emit(enemy_move.animation_name, enemy_move.duration)
		await get_tree().create_timer(time_step).timeout
	start_planning_phase()
	

func execute_action(current: BattleActorStats, other: BattleActorStats, move: MoveResource) -> void:
	current.current_beneficial_statuses = move.self_beneficial_statuses
	current.current_negative_statuses = move.self_negative_statuses
	current.hp += move.self_healing 
	if current.current_negative_statuses & 2:
		current.hp -= move.self_damage * 2
	else:
		current.hp -= move.self_damage
	if move.self_stats & 1:
		current.stat_array[0] += move.self_stat_modifier
	if move.self_stats & 2:
		current.stat_array[1] += move.self_stat_modifier
	if move.self_stats & 4:
		current.stat_array[2] += move.self_stat_modifier
	if move.self_stats & 8:
		current.stat_array[3] += move.self_stat_modifier
		
	other.current_beneficial_statuses = move.opponent_beneficial_statuses
	other.current_negative_statuses = move.opponent_negative_statuses
	other.hp += move.opponent_healing
	if ~(current.current_beneficial_statuses & other.current_beneficial_statuses):
		if other.current_negative_statuses & 2:
			other.hp -= move.opponent_damage * 2
		else:
			other.hp -= move.opponent_damage
	if move.self_stats & 1:
		other.stat_array[0] += move.opponent_stat_modifier
	if move.self_stats & 2:
		other.stat_array[1] += move.opponent_stat_modifier
	if move.self_stats & 4:
		other.stat_array[2] += move.opponent_stat_modifier
	if move.self_stats & 8:
		other.stat_array[3] += move.opponent_stat_modifier
	
	player_stats_updated.emit(player.hp)
	enemy_stats_updated.emit(enemy.hp)
