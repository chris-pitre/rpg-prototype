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
var equipped_weapon: ItemWeapon

func _ready() -> void:
	if RANDOM_SEED:
		rng.seed = Time.get_unix_time_from_system()
	else:
		rng.seed = 10
	equip_weapon(null)

func reset() -> void:
	day = -1
	population = 200
	gold = 0
	health = 5

func give_item(item: Item) -> bool:
	got_item.emit(item)
	return true

func learn_move(weapon_type: int, move: MoveResource) -> void:
	if not learned_actions.keys().has(weapon_type):
		learned_actions[weapon_type] = [move]
	elif not learned_actions[weapon_type].has(move):
		learned_actions[weapon_type].append(move)

func equip_weapon(weapon: ItemWeapon) -> void:
	if weapon:
		equipped_weapon = weapon
	else:
		equipped_weapon = load("res://resources/items/weapon_fists.tres")
	
	for move in equipped_weapon.starting_moves:
		learn_move(equipped_weapon.weapon_type, move)

func get_modified_move(move: MoveResource) -> MoveResource:
	var move_modified: MoveResource = move.duplicate()
	move_modified.opponent_damage = int(GameState.equipped_weapon.base_damage * move_modified.base_damage_mult)
	move_modified.opponent_damage += BattleManager.player.stat_block.damage_offset
	move_modified.opponent_posture_damage += BattleManager.player.stat_block.posture_damage_offset
	move_modified.self_damage += BattleManager.player.stat_block.self_damage_offset
	move_modified.self_posture_damage += BattleManager.player.stat_block.self_posture_damage_offset
	
	move_modified.windup += BattleManager.player.stat_block.windup_time_offset
	move_modified.active += BattleManager.player.stat_block.active_time_offset
	move_modified.recovery += BattleManager.player.stat_block.recovery_time_offset
	
	return move_modified

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
