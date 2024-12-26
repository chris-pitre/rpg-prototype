extends HBoxContainer

const EMPTY_BLOCK = preload("res://scenes/new_battle/empty_action_block.tscn")

@export var is_player_queue: bool = false

var action_blocks: Dictionary
var max_timestep: int = 32

func _ready() -> void:
	for i in range(max_timestep):
		var new_empty = EMPTY_BLOCK.instantiate()
		add_child(new_empty)

func update_blocks() -> void:
	pass

func add_action_block(index: int, timestep: int, action_block: ActionBlock) -> void:
	var action_range = range(index, index + action_block.action.length)
	var from_self = action_block in action_blocks.values()
	
	if not from_self: # dont remove empty space if already in action queue
		var to_remove: Array[Control] = []
		for i in action_range:
			to_remove.append(get_child(i))
		
		for node_to_remove in to_remove:
			remove_child(node_to_remove)
			node_to_remove.queue_free()
	
	if from_self:
		action_blocks.erase(action_blocks.find_key(action_block))
		for i in range(action_block.action.length):
			move_child(get_child(index), action_block.get_index())
		move_child(action_block, index)
		action_blocks[timestep] = action_block
	else:
		var new_action_block = action_block.duplicate()
		new_action_block.tree_exiting.connect(remove_action_block.bind(new_action_block))
		add_child(new_action_block)
		move_child(new_action_block, index)
		action_blocks[timestep] = new_action_block

func add_enemy_action_block(index: int, action_block: ActionBlock) -> void:
	pass

func remove_action_block(action_block: ActionBlock) -> void:
	var idx_to_replace = action_block.get_index()
	var amt_to_replace = action_block.action.length
	
	action_blocks.erase(action_blocks.find_key(action_block))
	if not action_block.is_queued_for_deletion():
		remove_child.call_deferred(action_block)
		action_block.queue_free()
	
	for i in range(amt_to_replace):
		var new_empty = EMPTY_BLOCK.instantiate()
		add_child.call_deferred(new_empty)
		move_child.call_deferred(new_empty, idx_to_replace)


func _on_action_block_delete_pressed(action_block: ActionBlock) -> void:
	remove_action_block(action_block)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not is_player_queue:
		return false
	
	if not data is ActionDragData:
		return false
	
	var action_block = data.source
	var can_drop: bool = true
	var action = action_block.action
	var index_from_pos = _position_to_index(at_position, action_block)
	var timestep_from_pos = _position_to_timestep(at_position)
	
	if timestep_from_pos + action.length > max_timestep: # Avoid running past end of queue
		return false
	
	var intersecting_timesteps = range(timestep_from_pos, timestep_from_pos + action.length)
	
	for occupied_timestep in action_blocks.keys():
		if action_blocks[occupied_timestep] == action_block: # dont check intersection if block intersects with itself; allow reordering
			continue
		
		if occupied_timestep in intersecting_timesteps:
			can_drop = false
	
	return can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var action_block = data.source
	
	add_action_block(_position_to_index(at_position, action_block), _position_to_timestep(at_position), action_block)

func _position_to_timestep(pos: Vector2) -> int:
	return floor((pos.x / size.x) * max_timestep)

func _position_to_index(pos: Vector2, data: Variant) -> int:
	var base_at_timestep = floor((pos.x / size.x) * max_timestep)
	
	var compensate_extra_length = 0
	for occupied_timestep: int in action_blocks.keys():
		var action_block: ActionBlock = action_blocks[occupied_timestep]
		if occupied_timestep <= base_at_timestep and not action_block == data:
			compensate_extra_length += (action_block.action.length - 1)
	
	return base_at_timestep - compensate_extra_length
