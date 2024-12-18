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
@export var success_result: MapEventResult
@export var fail_result: MapEventResult
@export var difficulty: int = 10
@export_enum("None", "Power", "Agility", "Speech", "Piety") var attribute_check: int = MapEventChoice.NONE
