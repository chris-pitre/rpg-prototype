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

var hp: int
var current_beneficial_statuses: int = 0
var current_negative_statuses: int = 0
var stat_array: Array[int] = [0, 0, 0, 0]
var posture: int = 100
var current_phase_state: PHASE_STATE = PHASE_STATE.BLOCKING

enum PHASE_STATE {
	WINDUP,
	ACTIVE,
	RECOVERY,
	BLOCKING
}

enum BENEFICIAL_STATUSES {
	HIGH_GUARD,
	MID_GUARD,
	LOW_GUARD
}

enum NEGATIVE_STATUSES {
	STUNNED,
	ENFEEBLED
}

func _init(p_name="John", p_max_hp=10, p_power=0, p_speech=0, p_agility=0, p_piety=0, p_moves:Array[String] = [], p_sprite_frames: SpriteFrames=null, p_animation_lib: AnimationLibrary=null) -> void:
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
	hp = max_hp

func reset_stats() -> void:
	stat_array[0] = power
	stat_array[1] = speech
	stat_array[2] = agility
	stat_array[3] = piety