class_name MapEventResult
extends Resource

@export var title: String = "Result"
@export var description: String = "Something has happened."
@export var encounter: Encounter
@export var gold: int = 0
@export var population_change: int = 0
@export var items: Array[Item] = []
