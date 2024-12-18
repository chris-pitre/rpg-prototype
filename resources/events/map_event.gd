class_name MapEvent
extends Resource

@export var name: String = "Event"
@export var road_event: bool = false
@export_multiline var hover_description: String = "Something is happening."
@export_multiline var description: String = "Something is happening."
@export var lifetime: int = -1
@export var choices: Array[MapEventChoice] = []
@export var neglect_result: MapEventResult
