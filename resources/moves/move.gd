class_name MoveResource extends Resource

@export var move_name: String
@export var move_animation: Animation:
	set(new_anim):
		move_animation = new_anim
		duration = move_animation.length if  move_animation != null else 0.0

@export_category("Self Effects")
@export_flags("High Guard", "Middle Guard", "Low Guard", "Stunned") var self_statuses: int = 0
@export var self_damage: int = 0
@export var self_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var self_stats: int = 0
@export var self_stat_modifier: int = 0

@export_category("Opponent Effects")
@export_flags("High Guard", "Middle Guard", "Low Guard", "Stunned") var opponent_statuses: int = 0
@export var opponent_damage: int = 0
@export var opponent_healing: int = 0
@export_flags("Power", "Speech", "Agility", "Piety") var opponent_stats: int = 0
@export var opponent_stat_modifier: int = 0

var duration: float = 0.0

func _init(p_move_name="Attack", p_move_animation=null):
	move_name = p_move_name
	move_animation = p_move_animation
	
