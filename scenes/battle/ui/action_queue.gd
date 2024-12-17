extends NinePatchRect

@onready var move_drop_template = preload("res://scenes/battle/ui/move_drop.tscn")
@onready var queue_loc = $MarginContainer/MoveTimeline

func _ready() -> void:
	BattleManager.connect("UI_move_added", _add_move)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is MoveResource and data != null and BattleManager.filled_duration >= data.duration
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	_add_move(data)
		
func _add_move(data: MoveResource) -> void:
	BattleManager.move_added(data)
	var move_drop = move_drop_template.instantiate()
	move_drop.move_resource = data
	move_drop.set_h_size_flags(0)
	move_drop.custom_minimum_size = Vector2(data.duration * queue_loc.size[0], 0)
	move_drop.is_queued = true
	queue_loc.add_child(move_drop)
