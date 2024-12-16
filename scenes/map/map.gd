class_name WorldMap
extends Control

enum LOCATIONS {
	CAMP,
	OUTLANDS,
	BLACKSMITH,
	CHAMBERS,
	MARKET,
	MEDICAL,
	FARM,
	SLUMS,
	ACADEMY
}

enum EVENTS {
	NONE,
	JOBBER,
	CHOICE,
	LONG
}

enum RESULT {
	NONE,
	DEATH,
	LIFE,
	UNREST,
	RICH
}

var adjacent: Dictionary = {}
var events: Array = [
	{},
	{
		3: EVENTS.LONG,
		7: EVENTS.LONG
	},
	{},
	{
		4: EVENTS.CHOICE
	},
	{
		5: EVENTS.CHOICE
	},
	{},
	{
		0: EVENTS.JOBBER
	},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{}
]

var player_tween: Tween
var day: int = -1

@onready var map_locations: Array[MapLocation]
@onready var location_container = $Locations
@onready var current_location = location_container.get_child(0)
@onready var player = $Player
@onready var choice_panel = $CanvasLayer/Overlay/ChoicePanel
@onready var choice_container = choice_panel.get_node("ChoiceContainer")
@onready var event_panel = $CanvasLayer/Overlay/EventInfoPanel
@onready var event_text = event_panel.get_node("EventInfoContainer/EventText")
@onready var camera = $Camera2D
@onready var visit_button = $CanvasLayer/Overlay/VisitButton
@onready var blacksmith_menu = $CanvasLayer/Overlay/BlacksmithMenu
@onready var medical_menu = $CanvasLayer/Overlay/MedicalMenu
@onready var market_menu = $CanvasLayer/Overlay/MarketMenu

func _ready() -> void:
	add_road(LOCATIONS.CAMP, LOCATIONS.OUTLANDS)
	add_road(LOCATIONS.OUTLANDS, LOCATIONS.MARKET)
	add_road(LOCATIONS.BLACKSMITH, LOCATIONS.CHAMBERS)
	add_road(LOCATIONS.CHAMBERS, LOCATIONS.MARKET)
	add_road(LOCATIONS.CHAMBERS, LOCATIONS.MARKET)
	add_road(LOCATIONS.CHAMBERS, LOCATIONS.ACADEMY)
	add_road(LOCATIONS.MEDICAL, LOCATIONS.FARM)
	add_road(LOCATIONS.ACADEMY, LOCATIONS.FARM)
	add_road(LOCATIONS.ACADEMY, LOCATIONS.SLUMS)
	add_road(LOCATIONS.ACADEMY, LOCATIONS.MARKET)
	player.global_position = current_location.global_position
	MapEvents.event_happened.connect(_map_event_happened)
	for child in location_container.get_children():
		if child is MapLocation:
			map_locations.append(child)
			child.pressed.connect(_map_location_pressed.bind(child))
	progress_time()
	print(map_locations)

func _draw() -> void:
	for key in adjacent.keys():
		var val = adjacent[key]
		for adj in val:
			draw_line(
				map_locations[key].global_position + Vector2.ONE * 16,
				map_locations[adj].global_position + Vector2.ONE * 16,
				Color.WHITE,
				6,
				true
			)

func _physics_process(delta: float) -> void:
	var move_vector = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	camera.global_position += move_vector * delta * 480.0

func progress_time() -> void:
	if day < events.size() - 1:
		day += 1
		for location in events[day].keys():
			map_locations[location].set_event(events[day][location])
		update_state()

func add_road(loc_one, loc_two) -> void:
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

func show_event_info(str: String) -> void:
	event_panel.show()
	event_text.text = str

func start_event(event_id: int) -> void:
	match event_id:
		EVENTS.JOBBER:
			pass
		EVENTS.CHOICE:
			show_choices(
				["Kill the bad guy", "Leave them be"],
				[RESULT.DEATH, RESULT.LIFE]
			)
		EVENTS.LONG:
			show_choices(
				["Pay your taxes", "Don't pay your taxes"],
				[RESULT.UNREST, RESULT.RICH]
			)

func show_choices(choices: Array[String], results: Array[RESULT]):
	for choice in choice_container.get_children():
		if choice is Button:
			choice.queue_free()
	choice_panel.show()
	for choice in range(choices.size()):
		var new_choice = Button.new()
		new_choice.size_flags_vertical = SIZE_EXPAND_FILL
		new_choice.text = choices[choice]
		choice_container.add_child(new_choice)
		new_choice.pressed.connect(
			func():
				choice_panel.hide()
				apply_result(results[choice])
		)

func apply_result(result_id: int):
	match result_id:
		RESULT.NONE:
			show_event_info("Nothing happened.")
		RESULT.DEATH:
			show_event_info("The bad guy was actually a good guy and his blood is on your hands!")
		RESULT.LIFE:
			show_event_info("The bad guy is actually pretty chill and he saved a family from a feral bear attack.")
		RESULT.UNREST:
			show_event_info("You paid too many taxes and billions have fallen")
		RESULT.RICH:
			show_event_info("You are freakin' rich!")

func start_battle() -> void:
	pass

func visit_location(location: MapLocation) -> void:
	if location.current_event > 0:
		start_event(location.current_event)
		location.current_event = 0
	match map_locations.find(location):
		LOCATIONS.BLACKSMITH:
			visit_button.show()
		LOCATIONS.MARKET:
			visit_button.show()
		LOCATIONS.MEDICAL:
			visit_button.show()
		_:
			visit_button.hide()

func _map_location_pressed(map_location: MapLocation) -> void:
	if player_tween:
		if player_tween.is_running():
			return
	if adjacent[map_locations.find(current_location)].has(map_location.get_index()):
		if player_tween:
			player_tween.stop()
		player_tween = get_tree().create_tween()
		player_tween.tween_property(player, "global_position", map_location.global_position, 0.3)
		player_tween.finished.connect(_player_tween_finished)
		current_location = map_location

func _player_tween_finished() -> void:
	visit_location(current_location)
	progress_time()

func _on_event_okay_pressed() -> void:
	event_panel.hide()

func _map_event_happened(event_id) -> void:
	match event_id:
		EVENTS.JOBBER:
			show_event_info("A jobber stole all the money from the local citizens.")
		EVENTS.CHOICE:
			show_event_info("Mass hysteria has occurred because you didn't resolve a choice")
		EVENTS.LONG:
			show_event_info("Government has fallen")

func _on_visit_button_pressed() -> void:
	visit_button.hide()
	camera.global_position = current_location.global_position - get_viewport_rect().size / 2.0 + Vector2.ONE * 16
	match map_locations.find(current_location):
		LOCATIONS.BLACKSMITH:
			blacksmith_menu.show()
		LOCATIONS.MARKET:
			market_menu.show()
		LOCATIONS.MEDICAL:
			medical_menu.show()

func _on_close_blacksmith_pressed() -> void:
	blacksmith_menu.hide()

func _on_close_market_pressed() -> void:
	market_menu.hide()

func _on_close_medical_pressed() -> void:
	medical_menu.hide()
