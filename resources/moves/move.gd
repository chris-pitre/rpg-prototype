class_name MoveResource extends Resource

@export var name: String
@export var animation_name: String = "<null>"
@export var windup: int = 1
@export var active: int = 1
@export var recovery: int = 1
var length: int:
	get:
		return windup + active + recovery

@export_category("Self Effects")
@export_flags("High Guard", "Middle Guard", "Low Guard") var self_beneficial_statuses: int = 0
@export_flags("Stunned", "Enfeebled") var self_negative_statuses: int = 0
@export var self_damage: int = 0
@export var self_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var self_stats: int = 0
@export var self_stat_modifier: int = 0

@export_category("Opponent Effects")
@export_flags("High Guard", "Middle Guard", "Low Guard") var opponent_beneficial_statuses: int = 0
@export_flags("Stunned", "Enfeebled") var opponent_negative_statuses: int = 0
@export var opponent_damage: int = 0
@export var opponent_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var opponent_stats: int = 0
@export var opponent_stat_modifier: int = 0

func _init(p_name="Attack", p_animation_name="<null>"):
	name = p_name
	animation_name = p_animation_name
	
