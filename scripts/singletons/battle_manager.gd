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

const MOVES_DIR = "res://resources/moves/"

var moves = {}
var battle_active: bool = false
var current_encounter: Encounter
var current_phase: PHASES
var current_enemy = null
var execution_timer: Timer

var max_timestep: int = 60
var time_step: float = 0.05
var queued_player_moves: Dictionary = {}
var queued_enemy_moves: Dictionary = {}

var player: BattleActorStats = preload("res://resources/battle_actor/test_player.tres")
var enemy: BattleActorStats

func _ready() -> void:
	start_battle.connect(start_new_battle)
	
	var dir = DirAccess.open(MOVES_DIR)
	if dir:
		for file_name in dir.get_files():
			file_name = file_name.trim_suffix(".remap")
			var move = ResourceLoader.load(MOVES_DIR + "/" + file_name)
			if move is MoveResource:
				moves[move.name] = move

func start_new_battle(encounter: Encounter) -> void:
	current_encounter = encounter
	enemy = encounter.enemy.duplicate()
	battle_active = true
	player_stats_updated.emit(player.hp)
	enemy_stats_updated.emit(enemy.hp)
	await battle_started
	start_planning_phase()
	
func start_planning_phase() -> void:
	current_phase = PHASES.PLANNING
	planning_phase_started.emit()
	queued_player_moves = {}
	queued_enemy_moves = {}

func start_execution_phase() -> void:
	current_phase = PHASES.EXECUTION
	execution_phase_started.emit()
	for i in range(max_timestep):
		if player.hp <= 0:
			battle_ended.emit(current_encounter, false)
			break
		elif enemy.hp <= 0:
			battle_ended.emit(current_encounter, true)
			break
		var player_move = queued_player_moves.get(i)
		var enemy_move = queued_enemy_moves.get(i)
		if player_move != null and player_move.action.animation_name != "<null>":
			player_animation.emit(player_move.action.animation_name, player_move.action)
		if enemy_move != null and enemy_move.action.animation_name != "<null>":
			enemy_animation.emit(enemy_move.action.animation_name, enemy_move.action)
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
