extends Node

#region Battle Flow Signals
signal start_battle(encounter: Encounter)

signal battle_started
signal battle_ended(encounter: Encounter, player_lost: bool)

signal planning_phase_started
signal execution_phase_started

signal next_execution_timestep
signal allow_move_execution
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
signal player_status_removed(status: StatStatus)
signal enemy_status_removed(status: StatStatus)

signal guard_switching_started
signal guard_switching_ended

signal clashed

#endregion

enum PHASES{
	PLANNING,
	EXECUTION
}

const MOVES_DIR = "res://resources/moves/"
const STUN_STATUS = preload("res://resources/statuses/stat_statuses/stunned_status.tres")

var moves = {}
var battle_active: bool = false
var current_encounter: Encounter
var current_phase: PHASES
var current_enemy = null
var execution_timer: Timer

var max_timestep: int = 60
var time_step: float = 0.12
var current_time_step: int = 0
var queued_player_moves: Dictionary = {}
var queued_enemy_moves: Dictionary = {}
var already_clashed: bool = false

var player: BattleActorStats = preload("res://resources/battle_actor/player.tres")
var enemy: BattleActorStats

var currently_guard_switching: bool = false

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
	player.stat_block = GameState.stat_block
	get_available_actions()
	refresh_stats()
	battle_active = true
	await battle_started
	start_planning_phase()
	
func start_planning_phase() -> void:
	current_phase = PHASES.PLANNING
	planning_phase_started.emit()

func start_execution_phase() -> void:
	current_phase = PHASES.EXECUTION
	execution_phase_started.emit()
	for i in range(max_timestep):
		already_clashed = false
		current_time_step = i
		if player.hp <= 0:
			battle_ended.emit(current_encounter, false)
			battle_active = false
			return
		elif enemy.hp <= 0:
			battle_ended.emit(current_encounter, true)
			battle_active = false
			return
		var player_move = queued_player_moves.get(i)
		var enemy_move = queued_enemy_moves.get(i)
		if player_move != null:
			player_start_move.emit(player_move.action)
		if enemy_move != null:
			enemy_start_move.emit(enemy_move.action)
		await get_tree().create_timer(time_step).timeout
		next_execution_timestep.emit()
		allow_move_execution.emit()
	start_planning_phase()
	

func execute_action(current: BattleActorStats, other: BattleActorStats, move: MoveResource) -> void:
	await allow_move_execution
	#interrupt execution of action if actor is stunned
	for stat_status: StatStatus in current.stat_modifiers:
		if stat_status.name == "Stunned":
			return
	
	#add guard if move adds it
	if move.self_guard_status != null:
		current.current_guard = move.self_guard_status.guard_type
	if move.opponent_guard_status != null:
		other.current_guard = move.opponent_guard_status.guard_type
		
	#interrupt execution of action if there is a clash
	if current.current_phase_state == BattleActorStats.PHASE_STATE.ACTIVE and other.current_phase_state == BattleActorStats.PHASE_STATE.ACTIVE:
		if not already_clashed:
			clashed.emit()
			already_clashed = true
		return
	
	#calculate healing and damage for current and opponent
	var hp_mult: int
	var posture_mult: int 
	
	if current.current_guard != GuardStatus.GUARD.NONE and current.current_guard == move.attack_direction:
		var receiver_move = get_move_at_timestep(other, current_time_step)
		var receiver_is_switching: bool = false
		if receiver_move:
			if receiver_move.guard_switching:
				receiver_is_switching = true
		
		if other.current_phase_state == BattleActorStats.PHASE_STATE.BLOCKING or get_move_at_timestep(other, current_time_step):
			hp_mult = 0.0
			posture_mult = 1.0
		else:
			hp_mult = 1.0
			posture_mult = 0.2
	else:
		if other.current_phase_state == BattleActorStats.PHASE_STATE.BLOCKING:
			hp_mult = 1.0
			posture_mult = 0.2
		else:
			hp_mult = 1.0
			posture_mult = 1.0
	for new_stat_status in current.stat_modifiers:
		match new_stat_status.damage_type:
			StatStatus.STAT_DAMAGE_TYPES.POSTURE:
				posture_mult += new_stat_status.multiplier
			StatStatus.STAT_DAMAGE_TYPES.HP:
				hp_mult += new_stat_status.multiplier
			StatStatus.STAT_DAMAGE_TYPES.BOTH:
				posture_mult += new_stat_status.multiplier
				hp_mult += new_stat_status.multiplier

	current.hp += move.self_healing
	current.hp -= move.self_damage * hp_mult
	current.posture -= move.self_posture_damage * posture_mult
	
	if other.current_guard != GuardStatus.GUARD.NONE and other.current_guard == move.attack_direction:
		var receiver_move = get_move_at_timestep(other, current_time_step)
		var receiver_is_switching: bool = false
		if receiver_move:
			if receiver_move.guard_switching:
				receiver_is_switching = true
		
		if current.current_phase_state == BattleActorStats.PHASE_STATE.BLOCKING or receiver_is_switching:
			hp_mult = 0.0
			posture_mult = 1.0
		else:
			hp_mult = 1.0
			posture_mult = 0.2
	else:
		if current.current_phase_state == BattleActorStats.PHASE_STATE.BLOCKING:
			hp_mult = 1.0
			posture_mult = 0.2
		else:
			hp_mult = 1.0
			posture_mult = 1.0
	for new_stat_status in other.stat_modifiers:
		match new_stat_status.damage_type:
			StatStatus.STAT_DAMAGE_TYPES.POSTURE:
				posture_mult += new_stat_status.multiplier
			StatStatus.STAT_DAMAGE_TYPES.HP:
				hp_mult += new_stat_status.multiplier
			StatStatus.STAT_DAMAGE_TYPES.BOTH:
				posture_mult += new_stat_status.multiplier
				hp_mult += new_stat_status.multiplier
	
	other.hp += move.opponent_healing
	other.hp -= move.opponent_damage * hp_mult
	other.posture -= move.opponent_posture_damage * posture_mult
	
	#add game stat modification
	
	#add stun if posture <= 0
	if current.posture <= 0:
		current.add_status(STUN_STATUS.instantiate().duplicate())
	if other.posture <= 0:
		other.add_status(STUN_STATUS.instantiate().duplicate())
	
	#add combat stat mods 
	for status in move.self_stat_statuses:
		current.add_status(status.duplicate())
	for status in move.opponent_stat_statuses:
		other.add_status(status.duplicate())

func refresh_stats() -> void:
	player_hp_updated.emit(player.hp)
	player_posture_updated.emit(player.posture)
	enemy_hp_updated.emit(enemy.hp)
	enemy_posture_updated.emit(enemy.posture)

func get_available_actions() -> void:
	player.moves.clear()
	for action in GameState.learned_actions[GameState.equipped_weapon.weapon_type]:
		player.moves.append(action.name)

func get_move_at_timestep(battle_actor_status: BattleActorStats, timestep: int) -> MoveResource:
	var queued_moves = queued_player_moves if battle_actor_status.is_player else queued_player_moves
	
	for move_timestep in queued_moves:
		var action_block: ActionBlock = queued_moves[move_timestep]
		var move: MoveResource = action_block.action
		
		if move_timestep <= timestep and move_timestep + move.length > timestep:
			return move
	
	return null
