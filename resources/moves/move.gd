class_name MoveResource extends Resource

@export var name: String
@export var animation_name: String = "<null>"

@export_category("Attack Characteristics")
@export_enum("None", "High Attack", "Middle Attack", "Low Attack") var attack_direction: int = 1
@export var windup: int = 1
@export var active: int = 1
@export var recovery: int = 1
var length: int:
	get:
		return windup + active + recovery

@export_category("Self Effects")
@export var self_stat_statuses: Array[StatStatus] = []
@export var self_guard_status: GuardStatus = null
@export var self_stun_status: StunnedStatus = null
@export var self_damage: int = 0
@export var self_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var self_stats: int = 0
@export var self_stat_modifier: int = 0

@export_category("Opponent Effects")
@export var opponent_stat_statuses: Array[StatStatus] = []
@export var opponent_guard_status: GuardStatus = null
@export var opponent_stun_status: StunnedStatus = null
@export var opponent_damage: int = 0
@export var opponent_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var opponent_stats: int = 0
@export var opponent_stat_modifier: int = 0

func _init(p_name="Attack", p_animation_name="<null>"):
	name = p_name
	animation_name = p_animation_name
	
