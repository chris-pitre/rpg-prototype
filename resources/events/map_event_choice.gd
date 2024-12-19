class_name MapEventChoice
extends Resource

enum {
	NONE,
	POWER,
	AGILITY,
	SPEECH,
	PIETY,
}

@export var text: String = "Choice"
@export var required_gold: int = 0
@export_enum("None", "Power", "Agility", "Speech", "Piety") var attribute_check: int = MapEventChoice.NONE
@export var difficulty: int = 10
@export var success_result: MapEventResult
@export var fail_result: MapEventResult
