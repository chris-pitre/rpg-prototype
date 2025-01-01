class_name BattleActorStats extends Resource

@export var name: String = ""
@export var is_player: bool = false
@export var max_hp: int = 100
@export var power: int = 0
@export var speech: int = 0
@export var agility: int = 0
@export var piety: int = 0
@export var moves: Array[String] = []
@export var move_queues: Array[EnemyMoveQueue] = []
@export var sprite_frames: SpriteFrames #placeholder for now will be replaced with whatever 3d implementation
@export var animation_lib: AnimationLibrary

var hp: int = 100: set = _set_hp
var posture: int = 100: set = _set_posture
var current_guard: GuardStatus.GUARD = GuardStatus.GUARD.NONE
var stat_modifiers: Array[StatStatus] = []
var stun: StunnedStatus = null: set = _set_stun
var stat_array: Array[int] = [0, 0, 0, 0]
var current_phase_state: PHASE_STATE = PHASE_STATE.BLOCKING

enum PHASE_STATE {
	WINDUP,
	ACTIVE,
	RECOVERY,
	BLOCKING
}

func _init(p_name="John", p_max_hp=100, p_power=0, p_speech=0, p_agility=0, p_piety=0, p_moves:Array[String] = [], p_sprite_frames: SpriteFrames=null, p_animation_lib: AnimationLibrary=null) -> void:
	name = p_name
	max_hp = p_max_hp
	power = p_power
	stat_array[0] = power
	speech = p_speech
	stat_array[1] = speech
	agility = p_agility
	stat_array[2] = agility
	piety = p_piety
	stat_array[3] = piety
	moves = p_moves

func reset_stats() -> void:
	stat_array[0] = power
	stat_array[1] = speech
	stat_array[2] = agility
	stat_array[3] = piety

func add_status(status: StatStatus) -> void:
	print(status)
	status.status_finished.connect(remove_status)
	if is_player:
		BattleManager.player_status_added.emit(status)
	else:
		BattleManager.enemy_status_added.emit(status)
	stat_modifiers.append(status)

func remove_status(status: StatStatus) -> void:
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
		BattleManager.player_guard_updated.emit()
	else:
		BattleManager.enemy_guard_updated.emit()
