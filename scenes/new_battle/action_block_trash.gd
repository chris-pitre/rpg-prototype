extends Panel

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ActionDragData and data.source.get_parent() is ActionQueue

func _drop_data(at_position: Vector2, data: Variant) -> void:
	data.source.get_parent().remove_action_block(data.source)
