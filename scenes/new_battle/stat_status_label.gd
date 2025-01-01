class_name StatStatusLabel
extends Label

var status_name: String = ""
var status_value: int = 0

func update_value() -> void:
	text = "%s %d" % [status_name, status_value]
	if status_value <= 0:
		queue_free()
	status_value -= 1
