extends Node

func _ready() -> void:
	BattleManager.start_battle.connect(swap_to_battle)
	BattleManager.battle_ended.connect(swap_to_map)

func swap_to_map(encounter: Encounter, victory: bool) -> void:
	$Map.show()
	$Map/Background.show()
	$Map/CanvasLayer.show()
	$Battle/CanvasLayer.hide()
	$Battle/PlayerActor.hide()
	$Battle/EnemyActor.hide()

func swap_to_battle(encounter: Encounter) -> void:
	$Map.hide()
	$Map/Background.hide()
	$Map/CanvasLayer.hide()
	$Battle/CanvasLayer.show()
	$Battle/PlayerActor.show()
	$Battle/EnemyActor.show()
