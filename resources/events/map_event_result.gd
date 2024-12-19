class_name MapEventResult
extends Resource

@export var title: String = "Result"
@export_multiline var description: String = "Something has happened."
@export var encounter: Encounter
@export var gold: int = 0
@export var population_change: int = 0
@export var items: Array[Item] = []
@export var flags_to_set: Array[String] = []
@export var flags_set_value: Array[bool] = []
