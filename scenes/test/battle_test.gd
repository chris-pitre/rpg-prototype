extends Node

@onready var test_encounter = preload("res://resources/encounters/test_encounter.tres")

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	BattleManager.start_battle.emit(test_encounter)
