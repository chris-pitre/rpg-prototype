class_name MapLocation
extends Button

var current_event: int = 0
var days_left: int = 0

@onready var event_icon = $EventIcon

func update_state() -> void:
	if current_event > 0:
		days_left -= 1
		update_icon()
		if days_left <= 0:
			apply_event(current_event)
	else:
		event_icon.texture = null

func update_icon() -> void:
	match days_left:
		3:
			event_icon.texture = load("res://assets/textures/icons/skull1.png")
		2:
			event_icon.texture = load("res://assets/textures/icons/skull2.png")
		1:
			event_icon.texture = load("res://assets/textures/icons/skull3.png")
		0: 
			event_icon.texture = null
		_:
			event_icon.texture = load("res://assets/textures/icons/reddot.png")

func set_event(event_id: int) -> void:
	current_event = event_id
	match event_id:
		WorldMap.EVENTS.JOBBER:
			days_left = 3
		WorldMap.EVENTS.CHOICE:
			days_left = 4
		WorldMap.EVENTS.LONG:
			days_left = 11

func apply_event(event_id: int) -> void:
	current_event = 0
	MapEvents.event_happened.emit(event_id)
