extends Node

@onready var map = $Map
@onready var battle = $Battle

func _ready() -> void:
	BattleManager.start_battle.connect(swap_to_battle)
	BattleManager.battle_ended.connect(swap_to_map)
	$Map.show()
	$Map/Background.show()
	$Map/CanvasLayer.show()
	$Battle.hide()
	$Battle/CanvasLayer.hide()

func swap_to_map(encounter: Encounter, victory: bool) -> void:
	$Map.show()
	$Map/Background.show()
	$Map/CanvasLayer.show()
	$Battle.hide()
	$Battle/CanvasLayer.hide()
	map.camera.make_current()

func swap_to_battle(encounter: Encounter) -> void:
	$Map.hide()
	$Map/Background.hide()
	$Map/CanvasLayer.hide()
	$Battle.show()
	$Battle/CanvasLayer.show()
	battle.camera.make_current()
