class_name BattleActor extends Resource

@export var name: String = ""
@export var max_hp: int = 10
@export var power: int = 10
@export var speech: int = 10
@export var agility: int = 10
@export var piety: int = 10
@export var moves: Array[MoveResource] = []

var hp: int

func _init(p_name="John", p_max_hp=10, p_power=10, p_speech=10, p_agility=10, p_piety=10, p_moves:Array[MoveResource] = []) -> void:
	name = p_name
	max_hp = p_max_hp
	power = p_power
	speech = p_speech
	agility = p_agility
	piety = p_piety
	moves = p_moves
	hp = max_hp
