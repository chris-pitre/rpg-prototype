extends Panel

#WARNING FIX THISSSSS!!!!!!!!!!!!!!!!!!!!!!!!
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ActionDragData

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.source.queue_free()
