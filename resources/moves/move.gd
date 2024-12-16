class_name MoveResource extends Resource

@export var move_name: String
@export_range(0, 1, 0.01) var duration: float 

func _init(p_move_name="Attack", p_duration=0.5):
	move_name = p_move_name
	duration = p_duration
