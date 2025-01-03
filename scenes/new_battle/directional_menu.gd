extends MarginContainer

signal switched_guard()

@onready var arrow_grid: GridContainer = $ArrowGrid
@onready var up: TextureRect = $ArrowGrid/Up
@onready var right: TextureRect = $ArrowGrid/Right
@onready var down: TextureRect = $ArrowGrid/Down
@onready var dir_indicator: Sprite2D = $DirIndicator

var current_guard = GuardStatus.GUARD.NONE

func _ready() -> void:
	dir_indicator.position = arrow_grid.position + arrow_grid.size / 2
	BattleManager.guard_switching_started.connect(_guard_switching_started)
	BattleManager.guard_switching_ended.connect(_guard_switching_ended)

func _process(delta: float) -> void:
	if visible:
		var input_vec = Input.get_vector("direction_left", "direction_right", "direction_up", "direction_down")
		
		var targ_pos = arrow_grid.position + arrow_grid.size / 2 + input_vec * 32
		dir_indicator.position = dir_indicator.position.lerp(targ_pos, delta * 25)
		
		var new_guard
		
		if (input_vec - Vector2.UP).length() < 0.1:
			up.modulate = Color.RED
			right.modulate = Color.WHITE
			down.modulate = Color.WHITE
			new_guard = GuardStatus.GUARD.HIGH_GUARD
		elif (input_vec - Vector2.RIGHT).length() < 0.1:
			up.modulate = Color.WHITE
			right.modulate = Color.RED
			down.modulate = Color.WHITE
			new_guard = GuardStatus.GUARD.MIDDLE_GUARD
		elif (input_vec - Vector2.DOWN).length() < 0.1:
			up.modulate = Color.WHITE
			right.modulate = Color.WHITE
			down.modulate = Color.RED
			new_guard = GuardStatus.GUARD.LOW_GUARD
		else:
			up.modulate = Color.WHITE
			right.modulate = Color.WHITE
			down.modulate = Color.WHITE
			new_guard = GuardStatus.GUARD.NONE
		
		if not current_guard == new_guard:
			BattleManager.player.current_guard = new_guard
			switched_guard.emit(new_guard)
			current_guard = new_guard
		
		queue_redraw()

func _guard_switching_started() -> void:
	visible = true

func _guard_switching_ended() -> void:
	visible = false
