extends Node

signal day_changed(day: int)
signal got_item(item: Item)
signal got_action(action: BattleAction)
signal population_changed(amt: int)
signal gold_changed(amt: int)
signal max_health_changed(amt: int)
signal health_changed(amt: int)
signal stat_block_changed(stat_block: StatBlock)

const RANDOM_SEED: bool = false

@onready var rng = RandomNumberGenerator.new()
var day: int = -1:
	set = _set_day
var population: int = 200:
	set = _set_population
var gold: int = 0:
	set = _set_gold
var max_health: int = 5:
	set = _set_max_health
var health: int = 5:
	set = _set_health
var learned_actions: Dictionary
var stat_block = StatBlock.new():
	set = _set_stat_block

func _ready() -> void:
	if RANDOM_SEED:
		rng.seed = Time.get_unix_time_from_system()
	else:
		rng.seed = 10

func reset() -> void:
	day = -1
	population = 200
	gold = 0
	health = 5

func give_item(item: Item) -> bool:
	got_item.emit(item)
	return true

func give_action(action: BattleAction) -> void:
	got_action.emit(action)

func learn_action(weapon_type: int, action: BattleAction) -> void:
	if not learned_actions.keys().has(weapon_type):
		learned_actions[weapon_type]
	elif not learned_actions[weapon_type].has(action):
		learned_actions[weapon_type].append(action)

func _set_population(amt: int) -> void:
	population = amt
	population_changed.emit(amt)

func _set_gold(amt: int) -> void:
	gold = amt
	gold_changed.emit(amt)

func _set_max_health(amt: int) -> void:
	max_health = amt
	max_health_changed.emit(amt)

func _set_health(amt: int) -> void:
	health = amt
	health_changed.emit(amt)

func _set_day(_day: int) -> void:
	day = _day
	day_changed.emit(day)

func _set_stat_block(_stat_block: StatBlock) -> void:
	stat_block = _stat_block
	stat_block_changed.emit(stat_block)
