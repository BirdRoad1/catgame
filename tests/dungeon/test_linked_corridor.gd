extends "res://tests/test_case.gd"
## Tests for LinkedCorridor in scenes/dungeon/daungeon_system.gd.
## Inner classes and enums are reached through the script, no scene or node needed.

const DungeonSystem = preload("res://scenes/dungeon/daungeon_system.gd")
const LinkedCorridor = DungeonSystem.Corridor
const Dungeon = DungeonSystem.Dungeon
const Direction = DungeonSystem.Direction

var corridor


func before_each() -> void:
	# Fixed seed so random generation gives the same result every run
	seed(1234567)
	corridor = LinkedCorridor.new()


# --- Example: shows the pattern, and checks the runner works ---

func test_directions_line_up_with_array_indices() -> void:
	assert_eq(Direction.NORTH, 0)
	assert_eq(Direction.EAST, 1)
	assert_eq(Direction.SOUTH, 2)
	assert_eq(Direction.WEST, 3)


func test_new_corridor_has_four_direction_slots() -> void:
	assert_eq(corridor.directions.size(), 4)


# --- init() ---


func test_cool() -> void:
	var dungeon = Dungeon.new()
	dungeon.init()
	var start = dungeon.current_corridor
	var start_id = start.get_instance_id()
	print("START corridor id: ", start_id, " ", start)
	dungeon.dump_current()
	dungeon.go_direction(Direction.WEST)
	dungeon.dump_current()
	dungeon.go_direction(Direction.WEST)
	dungeon.dump_current()
	dungeon.go_direction(Direction.NORTH)
	dungeon.dump_current()
	dungeon.go_direction(Direction.EAST)
	dungeon.dump_current()
	dungeon.go_direction(Direction.NORTH)
	dungeon.dump_current()

	# Retrace steps: reverse order, opposite directions
	dungeon.go_direction(Direction.SOUTH)
	dungeon.dump_current()
	dungeon.go_direction(Direction.WEST)
	dungeon.dump_current()
	dungeon.go_direction(Direction.SOUTH)
	dungeon.dump_current()
	dungeon.go_direction(Direction.EAST)
	dungeon.dump_current()
	dungeon.go_direction(Direction.EAST)
	dungeon.dump_current()

	var end_id = dungeon.current_corridor.get_instance_id()
	print("END corridor id: ", end_id, " ", dungeon.current_corridor)
	print("Same corridor? ", end_id == start_id, " / same ref? ", dungeon.current_corridor == start)



func test_init_keeps_directions_that_were_passed_in() -> void:
	pending()


func test_init_without_dead_ends_opens_at_least_one_direction() -> void:
	pending()


func test_init_with_dead_ends_allowed_can_open_zero_directions() -> void:
	pending("try several seeds and check at least one gives a dead end")


func test_init_never_opens_more_than_four_directions() -> void:
	pending()


func test_init_is_repeatable_with_the_same_seed() -> void:
	pending()


# --- go_direction() ---

func test_go_direction_into_a_wall_is_rejected() -> void:
	pending()


func test_go_direction_into_an_open_corridor_returns_it() -> void:
	pending()


# --- Linking ---

func test_corridors_link_back_the_way_you_came() -> void:
	pending("going NORTH then SOUTH should return to the starting corridor")


func test_revisited_corridor_is_remembered_not_regenerated() -> void:
	pending()
