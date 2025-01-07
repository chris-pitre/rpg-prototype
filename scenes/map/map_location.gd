class_name MapLocation
extends Button

@export var location_name: String = "Location"

var current_event: MapEvent
var days_left: int = 0

@onready var event_icon = $EventIcon
@onready var days_text = $DaysText

func update_state() -> void:
	if current_event:
		days_left -= 1
		if days_left > 0:
			days_text.text = str(days_left)
			days_text.visible = true
		elif days_left == 0:
			days_text.visible = false
			apply_event(current_event)
		else:
			days_text.visible = false
		update_icon()
	else:
		days_text.visible = false
		event_icon.texture = null
		

func update_icon() -> void:
	if not current_event:
		$NotUrgent.visible = false
		return
	
	if current_event.urgent:
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
		$NotUrgent.visible = false
	else:
		event_icon.texture = null
		$NotUrgent.visible = true

func set_event(event: MapEvent) -> void:
	current_event = event
	days_left = event.lifetime + 1
	tooltip_text = event.hover_description

func apply_event(event: MapEvent) -> void:
	current_event = null
	tooltip_text = ""
	MapEvents.event_neglected.emit(event)
