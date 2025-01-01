class_name MoveResource extends Resource

@export_category("Attack Metadata")
@export var name: String
@export var windup_anim_name: String 
@export var active_anim_name: String
@export var recovery_anim_name: String

@export_category("Attack Characteristics")
@export_enum("None", "High Attack", "Middle Attack", "Low Attack") var attack_direction: int = 1
@export var windup: int = 1
@export var active: int = 1
@export var recovery: int = 1
var length: int = -1:
	get:
		if length == -1:
			length = windup + active + recovery
			if followup_attack != null:
				length += followup_attack.length
		return length
@export var followup_attack: MoveResource

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

func _init(p_name="Attack"):
	name = p_name
