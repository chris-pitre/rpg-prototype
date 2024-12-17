@tool
class_name MoveButton extends Button

@export var move_res: MoveResource:
	set(new_move):
		if new_move != null:
			move_res = new_move
			text = move_res.move_name
