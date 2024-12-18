class_name EnemyMoveQueue extends Resource

@export var queue: Array[Dictionary] = []

func _init(p_queue = [{}]) -> void:
	queue = p_queue
