extends Node

#region Battle Flow Signals
signal start_battle(encounter: Encounter)

signal battle_started
signal battle_ended(encounter: Encounter, player_lost: bool)

signal planning_phase_started
signal execution_phase_started

signal next_execution_timestep
#endregion

signal UI_move_added(move: MoveResource)

#region Battle Actor Signals
signal player_start_move(move: MoveResource)
signal enemy_start_move(move: MoveResource)

signal player_hp_updated(new_hp: int)
signal enemy_hp_updated(new_hp: int)

signal player_guard_updated
signal enemy_guard_updated

signal player_posture_updated(new_posture: int)
signal enemy_posture_updated(new_posture: int)

signal player_status_added(status: StatStatus)
signal enemy_status_added(status: StatStatus)
#endregion

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
var time_step: float = 0.1
var queued_player_moves: Dictionary = {}
var queued_enemy_moves: Dictionary = {}

var player: BattleActorStats = preload("res://resources/battle_actor/test_player.tres")
var enemy: BattleActorStats

var posture_stun = preload("res://resources/statuses/custom_statuses/stunned_status.tres")

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
	refresh_stats()
	battle_active = true
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
		if player.stun != null:
			player.stun.decrease_stun()
			if not player.stun.check_stun():
				player.posture = 100
				player.stun = null
		if enemy.stun != null:
			enemy.stun.decrease_stun()
			if not enemy.stun.check_stun():
				enemy.posture = 100
				enemy.stun = null
		var player_move = queued_player_moves.get(i)
		var enemy_move = queued_enemy_moves.get(i)
		if player_move != null:
			player_start_move.emit(player_move.action)
		if enemy_move != null:
			enemy_start_move.emit(enemy_move.action)
		await get_tree().create_timer(time_step).timeout
		next_execution_timestep.emit()
	start_planning_phase()
	

func execute_action(current: BattleActorStats, other: BattleActorStats, move: MoveResource) -> void:
	if current.stun != null and current.stun.check_stun():
		return
	
	if move.self_guard_status != null:
		current.current_guard = move.self_guard_status.guard_type
	if move.opponent_guard_status != null:
		other.current_guard = move.opponent_guard_status.guard_type
	
	current.hp += move.self_healing 
	if current.current_guard != GuardStatus.GUARD.NONE and current.current_guard == move.attack_direction:
		var damage_mult: float = 1.0
		for new_stat_status in current.stat_modifiers:
			if new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.POSTURE or new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.BOTH:
				damage_mult += new_stat_status.multiplier
		current.posture -= move.self_damage * damage_mult
		if current.posture <= 0:
			current.stun = posture_stun.duplicate()
	else:
		var damage_mult: float = 1.0
		for new_stat_status in current.stat_modifiers:
			if new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.HP or new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.BOTH:
				damage_mult += new_stat_status.multiplier
		current.hp -= move.self_damage
	
	other.hp += move.opponent_healing 
	if other.current_guard != GuardStatus.GUARD.NONE and other.current_guard == move.attack_direction:
		var damage_mult: float = 1.0
		for new_stat_status in other.stat_modifiers:
			if new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.POSTURE or new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.BOTH:
				damage_mult += new_stat_status.multiplier
		other.posture -= move.opponent_damage * damage_mult
		if other.posture <= 0:
			other.stun = posture_stun.duplicate()
	else:
		var damage_mult: float = 1.0
		for new_stat_status in other.stat_modifiers:
			if new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.HP or new_stat_status.damage_type == StatStatus.STAT_DAMAGE_TYPES.BOTH:
				damage_mult += new_stat_status.multiplier
		other.hp -= move.opponent_damage
		
	if move.self_stats & 1:
		current.stat_array[0] += move.self_stat_modifier
	if move.self_stats & 2:
		current.stat_array[1] += move.self_stat_modifier
	if move.self_stats & 4:
		current.stat_array[2] += move.self_stat_modifier
	if move.self_stats & 8:
		current.stat_array[3] += move.self_stat_modifier

	if move.self_stats & 1:
		other.stat_array[0] += move.opponent_stat_modifier
	if move.self_stats & 2:
		other.stat_array[1] += move.opponent_stat_modifier
	if move.self_stats & 4:
		other.stat_array[2] += move.opponent_stat_modifier
	if move.self_stats & 8:
		other.stat_array[3] += move.opponent_stat_modifier
	
	if move.self_stun_status != null:
		current.stun = move.self_stun_status.duplicate()
	if move.opponent_stun_status != null:
		other.stun = move.opponent_stun_status.duplicate()
	
	if not move.self_stat_statuses.is_empty():
		for status in move.self_stat_statuses:
			current.add_status(status.duplicate())
	if not move.opponent_stat_statuses.is_empty():
		for status in move.opponent_stat_statuses:
			other.add_status(status.duplicate())

func refresh_stats() -> void:
	player_hp_updated.emit(player.hp)
	player_posture_updated.emit(player.posture)
	enemy_hp_updated.emit(enemy.hp)
	enemy_posture_updated.emit(enemy.posture)
