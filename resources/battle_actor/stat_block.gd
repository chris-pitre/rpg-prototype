class_name StatBlock
extends Resource

@export var damage_offset: int = 0
@export var posture_damage_offset: int = 0
@export var windup_time_offset: int = 0
@export var active_time_offset: int = 0
@export var recovery_time_offset: int = 0
@export var damage_defense: int = 0
@export var posture_defense: int = 0
@export var stat_power_offset: int = 0
@export var stat_agility_offset: int = 0
@export var stat_speech_offset: int = 0
@export var stat_piety_offset: int = 0

func add(stat_block: StatBlock) -> StatBlock:
	var new_stat_block = StatBlock.new()
	new_stat_block.damage_offset = self.damage_offset + stat_block.damage_offset
	new_stat_block.posture_damage_offset = self.posture_damage_offset + stat_block.posture_damage_offset
	new_stat_block.damage_defense = self.damage_defense + stat_block.damage_defense
	new_stat_block.posture_defense = self.posture_defense + stat_block.posture_defense
	new_stat_block.windup_time_offset = self.windup_time_offset + stat_block.windup_time_offset
	new_stat_block.active_time_offset = self.active_time_offset + stat_block.active_time_offset
	new_stat_block.recovery_time_offset = self.recovery_time_offset + stat_block.recovery_time_offset
	new_stat_block.stat_power_offset = self.stat_power_offset + stat_block.stat_power_offset
	new_stat_block.stat_agility_offset = self.stat_agility_offset + stat_block.stat_agility_offset
	new_stat_block.stat_speech_offset = self.stat_speech_offset + stat_block.stat_speech_offset
	new_stat_block.stat_piety_offset = self.stat_piety_offset + stat_block.stat_piety_offset
	return new_stat_block

func sub(stat_block: StatBlock) -> StatBlock:
	var new_stat_block = StatBlock.new()
	new_stat_block.damage_offset = self.damage_offset - stat_block.damage_offset
	new_stat_block.posture_damage_offset = self.posture_damage_offset + stat_block.posture_damage_offset
	new_stat_block.damage_defense = self.damage_defense - stat_block.damage_defense
	new_stat_block.posture_defense = self.posture_defense - stat_block.posture_defense
	new_stat_block.windup_time_offset = self.windup_time_offset - stat_block.windup_time_offset
	new_stat_block.active_time_offset = self.active_time_offset - stat_block.active_time_offset
	new_stat_block.recovery_time_offset = self.recovery_time_offset - stat_block.recovery_time_offset
	new_stat_block.stat_power_offset = self.stat_power_offset - stat_block.stat_power_offset
	new_stat_block.stat_agility_offset = self.stat_agility_offset - stat_block.stat_agility_offset
	new_stat_block.stat_speech_offset = self.stat_speech_offset - stat_block.stat_speech_offset
	new_stat_block.stat_piety_offset = self.stat_piety_offset - stat_block.stat_piety_offset
	return new_stat_block
