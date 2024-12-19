class_name EnemyMoveQueue extends Resource

@export var queue: Dictionary = {}

func _init(p_queue = {}) -> void:
	queue = p_queue
