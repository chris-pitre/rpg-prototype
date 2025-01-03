class_name BattleActorStats extends Resource

@export var name: String = ""
@export var is_player: bool = false
@export var max_hp: int = 100
@export var moves: Array[String] = []
@export var move_queues: Array[EnemyMoveQueue] = []
@export var sprite_frames: SpriteFrames #placeholder for now will be replaced with whatever 3d implementation

var hp: int = 100: set = _set_hp
var posture: int = 100: set = _set_posture
var current_guard: GuardStatus.GUARD = GuardStatus.GUARD.NONE: set = _set_guard
var stat_modifiers: Array[StatStatus] = []
var stun: StunnedStatus = null: set = _set_stun
var stat_block: StatBlock = StatBlock.new()
var current_phase_state: PHASE_STATE = PHASE_STATE.BLOCKING

enum PHASE_STATE {
	WINDUP,
	ACTIVE,
	RECOVERY,
	BLOCKING
}

func _init(p_name="John", p_max_hp=100, p_moves:Array[String] = []) -> void:
	name = p_name
	max_hp = p_max_hp
	moves = p_moves

func add_status(status: StatStatus) -> void:
	BattleManager.next_execution_timestep.connect(status.decrease_duration.bind(self))
	status.status_finished.connect(remove_status)
	if is_player:
		BattleManager.player_status_added.emit(status)
	else:
		BattleManager.enemy_status_added.emit(status)
	stat_modifiers.append(status)

func remove_status(status: StatStatus) -> void:
	status.status_finished.disconnect(remove_status)
	BattleManager.next_execution_timestep.disconnect(status.decrease_duration)
	stat_modifiers.erase(status)

func _set_hp(new_hp: int) -> void:
	hp = new_hp
	if is_player:
		BattleManager.player_hp_updated.emit(new_hp)
	else:
		BattleManager.enemy_hp_updated.emit(new_hp)

func _set_posture(new_posture: int) -> void:
	posture = new_posture
	if is_player:
		BattleManager.player_posture_updated.emit(new_posture)
	else:
		BattleManager.enemy_posture_updated.emit(new_posture)

func _set_stun(new_stun: StunnedStatus) -> void:
	stun = new_stun
	if stun != null:
		stun.stun = stun.stun_timesteps

func _set_guard(new_guard: GuardStatus.GUARD) -> void:
	current_guard = new_guard
	if is_player:
		BattleManager.player_guard_updated.emit(new_guard)
	else:
		BattleManager.enemy_guard_updated.emit(new_guard)
