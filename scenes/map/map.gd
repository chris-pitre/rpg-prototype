class_name WorldMap
extends Control

signal location_resolved

const ITEM_BUTTON = preload("res://scenes/inventory/item_button.tscn")
const EVENTS_DIR = "res://resources/events/"
const EVENT_SCHEDULE_PATH = "res://resources/events/event_schedule.json"
const TIME_SCALE = 3

var event_schedule: Dictionary
var road_events: Dictionary = {}
var events: Dictionary = {}
var adjacent: Dictionary = {}

var player_tween: Tween
var current_encounter: Encounter
var event_flags: Array[String] = []
var cam_zoom: float = 0.0
var mouse_drag: bool = false

@onready var map_locations: Array[MapLocation]

@onready var location_container = $Locations
@onready var current_location = location_container.get_child(0)
@onready var player = $Player
@onready var choice_panel = $CanvasLayer/Overlay/ChoicePanel
@onready var choice_container = choice_panel.get_node("ChoiceContainer")
@onready var choice_title = choice_container.get_node("ChoiceTitle")
@onready var choice_description = choice_container.get_node("ChoiceDescription")
@onready var result_cover = $CanvasLayer/Overlay/ResultCover
@onready var result_panel = $CanvasLayer/Overlay/ResultCover/ResultPanel
@onready var result_container = result_panel.get_node("ResultContainer")
@onready var result_title = result_container.get_node("ResultTitle")
@onready var result_description = result_container.get_node("ResultDescription")
@onready var result_okay = result_container.get_node("ResultOkay")
@onready var result_fight = result_container.get_node("ResultFight")
@onready var camera = $Camera2D
@onready var visit_button = $CanvasLayer/Overlay/VisitButton
@onready var blacksmith_menu = $CanvasLayer/Overlay/BlacksmithMenu
@onready var medical_menu = $CanvasLayer/Overlay/MedicalMenu
@onready var market_menu = $CanvasLayer/Overlay/MarketMenu
@onready var item_menu = $CanvasLayer/Overlay/ItemResultMenu
@onready var item_menu_container = item_menu.get_node("Panel/VBoxContainer/ItemContainer")
@onready var academy_menu = $CanvasLayer/Overlay/AcademyMenu

func _ready() -> void:
	MapEvents.event_neglected.connect(_map_event_neglected)
	GameState.day_changed.connect(_day_changed)
	GameState.got_item.connect(_got_item)
	GameState.gold_changed.connect(_gold_changed)
	GameState.population_changed.connect(_population_changed)
	BattleManager.battle_ended.connect(end_encounter)
	
	player.global_position = current_location.global_position
	
	for child in location_container.get_children():
		if child is MapLocation:
			map_locations.append(child)
			child.pressed.connect(_map_location_pressed.bind(child))
	
	add_road("Camp", "Woods")
	add_road("Woods", "Countryside")
	add_road("Countryside", "Market")
	add_road("Blacksmith", "Chambers")
	add_road("Chambers", "Market")
	add_road("Chambers", "Market")
	add_road("Chambers", "Academy")
	add_road("Chambers", "Pub")
	add_road("Market", "Slums")
	add_road("Academy", "Market")
	add_road("Academy", "Pub")
	add_road("Blacksmith", "Pub")
	add_road("Medical", "Pub")
	add_road("Farm", "Woods")
	add_road("Farm", "Countryside")
	add_road("Academy", "Slums")
	add_road("Academy", "Market")
	add_road("Medical", "Cliffs")
	add_road("Blacksmith", "Cliffs")
	add_road("Wall", "Slums")
	add_road("Wall", "Logging")
	add_road("Countryside", "Lake")
	add_road("Cliffs", "Chasm")
	
	var dir = DirAccess.open(EVENTS_DIR)
	if dir:
		for file_name in dir.get_files():
			file_name = file_name.trim_suffix(".remap")
			var event = ResourceLoader.load(EVENTS_DIR + "/" + file_name)
			if event is MapEvent:
				if event.road_event:
					road_events[event.name] = event
				else:
					events[event.name] = event
	
	var file = FileAccess.open(EVENT_SCHEDULE_PATH, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		event_schedule = json.data
	
	progress_time()

func _draw() -> void:
	for key in adjacent.keys():
		var val = adjacent[key]
		for adj in val:
			if not (key.disabled or adj.disabled):
				draw_line(
					key.global_position + Vector2.ONE * 16,
					adj.global_position + Vector2.ONE * 16,
					Color.GRAY,
					6,
					true
				)
				draw_circle((key.global_position + adj.global_position + Vector2.ONE * 32) / 2, 10, Color.GRAY)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_zoom += 0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_zoom -= 0.1
		cam_zoom = clamp(cam_zoom, -0.5, 0.5)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_drag = event.pressed
	if event is InputEventMouseMotion:
		if mouse_drag:
			camera.global_position -= event.relative / (cam_zoom + 1.0)
	

func _process(delta: float) -> void:
	var move_vector = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	camera.global_position += move_vector * delta * 640.0
	if Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	camera.zoom = camera.zoom.lerp(Vector2.ONE * (cam_zoom + 1.0), delta * 32)

func get_location_by_name(name: String) -> MapLocation:
	for location in map_locations:
		if location.location_name == name:
			return location
	return null

func progress_time() -> void:
	if GameState.day < event_schedule.days.size(): #update to use MapEvent
		GameState.day += 1
		for location in event_schedule.days[GameState.day].keys():
			var event: MapEvent = events[event_schedule.days[GameState.day][location]]
			var has_required_flags: bool = true
			for required_flag in event.require_flags:
				if not required_flag in event_flags:
					has_required_flags = false
					break
			if has_required_flags:
				get_location_by_name(location).set_event(event)
		update_state()

func add_road(loc_one, loc_two) -> void:
	loc_one = get_location_by_name(loc_one)
	loc_two = get_location_by_name(loc_two)
	
	if adjacent.keys().has(loc_one):
		adjacent[loc_one].append(loc_two)
	else:
		adjacent[loc_one] = [loc_two]
	if adjacent.keys().has(loc_two):
		adjacent[loc_two].append(loc_one)
	else:
		adjacent[loc_two] = [loc_one]

func update_state() -> void:
	for map_location in map_locations:
		map_location.update_state()

func start_event(event: MapEvent) -> void:
	show_choices(event)

func show_choices(event: MapEvent):
	for choice in choice_container.get_children():
		if choice is Button:
			choice.queue_free()
	choice_panel.show()
	for choice in event.choices:
		var new_choice = Button.new()
		new_choice.size_flags_vertical = Control.SIZE_SHRINK_END
		new_choice.text = choice.text
		if choice.required_gold > 0:
			new_choice.text += " (%d gold)" % choice.required_gold
			if GameState.gold < choice.required_gold:
				new_choice.disabled = true
		match choice.attribute_check:
			MapEventChoice.POWER:
				new_choice.text += " (POW DC %d)" % choice.difficulty
			MapEventChoice.AGILITY:
				new_choice.text += " (AGI DC %d)" % choice.difficulty
			MapEventChoice.SPEECH:
				new_choice.text += " (SPC DC %d)" % choice.difficulty
			MapEventChoice.PIETY:
				new_choice.text += " (PTY DC %d)" % choice.difficulty
		choice_container.add_child(new_choice)
		new_choice.pressed.connect(
			func():
				choice_panel.hide()
				apply_choice(choice)
		)
		choice_title.text = event.name
		choice_description.text = event.description

func apply_choice(choice: MapEventChoice) -> void:
	if choice.fail_result:
		var roll = GameState.rng.randi_range(1, 20)
		match choice.attribute_check:
			MapEventChoice.POWER:
				roll += GameState.stat_block.stat_power_offset
			MapEventChoice.AGILITY:
				roll += GameState.stat_block.stat_agility_offset
			MapEventChoice.SPEECH:
				roll += GameState.stat_block.stat_speech_offset
			MapEventChoice.PIETY:
				roll += GameState.stat_block.stat_piety_offset
		if roll >= choice.difficulty:
			show_event_result(choice.success_result)
		else:
			show_event_result(choice.fail_result)
	elif choice.success_result:
		show_event_result(choice.success_result)

func show_event_result(result: MapEventResult) -> void:
	if result.items.size() > 0:
		show_items(result.items)
	
	GameState.gold += result.gold
	GameState.population += result.population_change
	for flag in result.flags_to_set:
		if not flag in event_flags:
			event_flags.append(flag)
			if flag.begins_with("Disable"):
				get_location_by_name(flag.substr(7)).disabled = true
	for flag in result.flags_to_erase:
		if flag in event_flags:
			event_flags.erase(flag)
			if flag.begins_with("Disable"):
				get_location_by_name(flag.substr(7)).disabled = false
	queue_redraw()
	
	if result.title.is_empty() and result.description.is_empty():
		if result.encounter:
			current_encounter = result.encounter
			start_encounter(current_encounter)
		else:
			result_cover.hide()
			resolve_location()
	else:
		result_title.text = result.title
		result_description.text = result.description
		if result.encounter:
			current_encounter = result.encounter
			result_cover.show()
			result_fight.show()
			result_okay.hide()
		else:
			result_cover.show()
			result_fight.hide()
			result_okay.show()

func start_encounter(encounter: Encounter) -> void:
	BattleManager.start_battle.emit(encounter)

func end_encounter(encounter: Encounter, player_victory: bool) -> void:
	if player_victory:
		show_event_result(encounter.encounter_success)
	else:
		show_event_result(encounter.encounter_failure)
	resolve_location()

func show_items(items: Array[Item]) -> void:
	$CanvasLayer/Overlay/ItemResultMenu.show()
	for child in item_menu_container.get_children():
		child.queue_free()
	for item in items:
		var new_item_button = ITEM_BUTTON.instantiate()
		item_menu_container.add_child(new_item_button)
		new_item_button.item = item
		new_item_button.allow_drag = true

func visit_location(location: MapLocation) -> void:
	if location.current_event == null:
		resolve_location()
	else:
		start_event(location.current_event)
		location.current_event = null
		location.tooltip_text = ""
	match location.location_name:
		"Blacksmith":
			visit_button.show()
		"Market":
			visit_button.show()
		"Medical":
			visit_button.show()
		"Academy":
			visit_button.show()
		_:
			visit_button.hide()

func move_to_location(map_location: MapLocation) -> void:
	player_tween = get_tree().create_tween()
	player_tween.tween_property(player, "global_position", map_location.global_position, 1.0)
	player_tween.finished.connect(_player_second_tween_finished.bind(map_location))

func get_midpoint_event() -> MapEvent:
	var roll = GameState.rng.rand_weighted([0.2, 0.8])
	var event_list = road_events.values()
	if roll == 0:
		var event = event_list[GameState.rng.randi_range(0, event_list.size() - 1)]
		return event
	return null

func resolve_location() -> void:
	location_resolved.emit()
	progress_time()

func _map_location_pressed(map_location: MapLocation) -> void:
	if player_tween:
		if player_tween.is_running():
			return
	
	if map_location == current_location:
		return
	
	if adjacent[current_location].has(map_location):
		visit_button.hide()
		player_tween = get_tree().create_tween()
		player_tween.tween_property(player, "global_position", (player.global_position + map_location.global_position) / 2.0, 1.0 / TIME_SCALE)
		player_tween.finished.connect(_player_first_tween_finished.bind(map_location))

func _player_first_tween_finished(map_location: MapLocation) -> void:
	var midpoint_event = get_midpoint_event()
	if midpoint_event:
		start_event(midpoint_event)
		await location_resolved
	player_tween = get_tree().create_tween()
	player_tween.tween_property(player, "global_position", map_location.global_position, 1.0 / TIME_SCALE)
	player_tween.finished.connect(_player_second_tween_finished.bind(map_location))

func _player_second_tween_finished(map_location: MapLocation) -> void:
	current_location = map_location
	visit_location(current_location)

func _on_result_okay_pressed() -> void:
	result_cover.hide()
	resolve_location()

func _on_result_fight_pressed() -> void:
	result_cover.hide()
	start_encounter(current_encounter)

func _map_event_neglected(event: MapEvent) -> void:
	if event.neglect_result:
		show_event_result(event.neglect_result)
		current_encounter = event.neglect_result.encounter

func _on_visit_button_pressed() -> void:
	visit_button.hide()
	camera.global_position = current_location.global_position + Vector2.ONE * 16
	match current_location.location_name:
		"Blacksmith":
			blacksmith_menu.show()
		"Market":
			market_menu.show()
		"Medical":
			medical_menu.show()
		"Academy":
			academy_menu.show()

func _on_close_blacksmith_pressed() -> void:
	blacksmith_menu.hide()
	visit_button.show()

func _on_close_market_pressed() -> void:
	market_menu.hide()
	visit_button.show()

func _on_close_medical_pressed() -> void:
	medical_menu.hide()
	visit_button.show()

func _on_close_academy_pressed() -> void:
	academy_menu.hide()
	visit_button.show()

func _on_open_character_pressed() -> void:
	$CanvasLayer/Overlay/CharacterMenu.show()

func _on_close_character_pressed() -> void:
	$CanvasLayer/Overlay/CharacterMenu.hide()

func _day_changed(day: int) -> void:
	$CanvasLayer/Overlay/ResourceBar/HBoxContainer/ResourceIndicator5/ResourceAmount.text = str(day)

func _gold_changed(amt: int) -> void:
	$CanvasLayer/Overlay/ResourceBar/HBoxContainer/ResourceIndicator3/ResourceAmount.text = str(amt)

func _population_changed(amt: int) -> void:
	$CanvasLayer/Overlay/ResourceBar/HBoxContainer/ResourceIndicator4/ResourceAmount.text = str(amt)

func _on_item_result_close_pressed() -> void:
	$CanvasLayer/Overlay/ItemResultMenu.hide()

func _got_item(item: Item) -> void:
	var new_item_button = ITEM_BUTTON.instantiate()
	$CanvasLayer/Overlay/CharacterMenu/Panel/VBoxContainer/ScrollContainer/Panel/ItemContainer.add_child(new_item_button)
	new_item_button.item = item

func _on_purchase_membership_pressed() -> void:
	if GameState.gold >= 50:
		GameState.gold -= 50
		$CanvasLayer/Overlay/BlacksmithMenu/HBoxContainer/Panel/VBoxContainer/MembershipContainer.hide()
		$CanvasLayer/Overlay/BlacksmithMenu/HBoxContainer/Panel/VBoxContainer/BlacksmithTabs.show()
