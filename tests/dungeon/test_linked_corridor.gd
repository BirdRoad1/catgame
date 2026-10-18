extends "res://tests/test_case.gd"
## Tests for Corridor in scenes/dungeon/dungeon_system.gd.
## Inner classes and enums are reached through the script, no scene or node needed.

const DungeonSystem = preload("res://scenes/dungeon/dungeon.gd")
const Corridor = DungeonSystem.Corridor
const Dungeon = DungeonSystem.Dungeon
const Direction = DungeonSystem.Direction

var corridor


func before_each() -> void:
	# Fixed seed so random generation gives the same result every run
	seed(1723487)
	corridor = Corridor.new()


# --- Example: shows the pattern, and checks the runner works ---

# func test_directions_line_up_with_array_indices() -> void:
# 	assert_eq(Direction.NORTH, 0)
# 	assert_eq(Direction.EAST, 1)
# 	assert_eq(Direction.SOUTH, 2)
# 	assert_eq(Direction.WEST, 3)


# func test_new_corridor_has_four_direction_slots() -> void:
# 	assert_eq(corridor.directions.size(), 4)


# --- init() ---

func get_first_direction(dungeon: Dungeon):
	for direction in range(4):
		var adjacent_corridor: Corridor = dungeon.get_adjacent_corridor(direction)
		if dungeon.can_move_direction(direction) && !adjacent_corridor.did_travel:
			return direction
	for direction in range(4):
		if dungeon.can_move_direction(direction):
			return direction
	return null

## First open direction leading to an untravelled corridor, or null.
func get_unvisited_direction(dungeon: Dungeon):
	for direction in range(4):
		var adjacent_corridor: Corridor = dungeon.get_adjacent_corridor(direction)
		if dungeon.can_move_direction(direction) && adjacent_corridor != null && !adjacent_corridor.did_travel:
			return direction
	return null

func count_untravelled(dungeon: Dungeon) -> int:
	var count = 0
	for loc in dungeon.map:
		if !dungeon.map[loc].did_travel:
			count += 1
	return count

## Depth-first backtracking walk. Goes to unvisited corridors first; when stuck,
## retraces the path back. Done when the path is empty (back at start, nothing left).
# func test_cool() -> void:

	# var dungeon = Dungeon.new()
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.WEST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.EAST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.SOUTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.EAST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.SOUTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.SOUTH)
	# dungeon.dump_current()
	# print("Can move back to origin? " + str(dungeon.can_move_direction(Direction.WEST)))

## Checks every corridor in the map against its neighbours.
func find_inconsistencies(dungeon: Dungeon) -> Array[String]:
	var problems: Array[String] = []
	for loc in dungeon.map:
		var c: Corridor = dungeon.map[loc]
		if c.did_travel && c.open_directions.is_empty():
			problems.append("%s travelled but has no exits (dead end)" % loc)
		for dir in range(4):
			var n_loc = dungeon.apply_direction(loc, dir)
			var n: Corridor = dungeon.map.get(n_loc)
			var opp = Dungeon.get_opposite_dir(dir)
			if c.can_move(dir):
				if n == null:
					problems.append("%s open %d but no corridor at %s" % [loc, dir, n_loc])
				elif !n.can_move(opp):
					problems.append("%s open %d but %s is walled back (%d)" % [loc, dir, n_loc, opp])
			elif n != null && n.can_move(opp):
				problems.append("%s walled %d but %s is open toward it" % [loc, dir, n_loc])
	return problems


	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.WEST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.NORTH)
	# dungeon.dump_current()

	# # Retrace steps: reverse order, opposite directions
	# dungeon.move_direction(Direction.SOUTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.WEST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.SOUTH)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.EAST)
	# dungeon.dump_current()
	# dungeon.move_direction(Direction.EAST)
	# dungeon.dump_current()

	# var end_id = dungeon.get_current_corridor().get_instance_id()
	# print("END corridor id: ", end_id, " ", dungeon.get_current_corridor())
	# print("Same corridor? ", end_id == start_id, " / same ref? ", dungeon.get_current_corridor() == start)



# func test_init_keeps_directions_that_were_passed_in() -> void:
# 	pending()


# func test_init_without_dead_ends_opens_at_least_one_direction() -> void:
# 	pending()


# func test_init_with_dead_ends_allowed_can_open_zero_directions() -> void:
# 	pending("try several seeds and check at least one gives a dead end")


# func test_init_never_opens_more_than_four_directions() -> void:
# 	pending()


# func test_init_is_repeatable_with_the_same_seed() -> void:
# 	pending()


# # --- move_direction() ---

# func test_move_direction_into_a_wall_is_rejected() -> void:
# 	pending()


# func test_move_direction_into_an_open_corridor_returns_it() -> void:
# 	pending()


# # --- Linking ---

# func test_corridors_link_back_the_way_you_came() -> void:
# 	pending("going NORTH then SOUTH should return to the starting corridor")


# func test_revisited_corridor_is_remembered_not_regenerated() -> void:
# 	pending()


## Depth-first backtracking walk for a bajillion steps, then walks all the way
## back to start and checks every corridor against its neighbours.
## Also fails if the dungeon runs out of places to explore before the step cap.
func test_long_walk() -> void:
	var dungeon = Dungeon.new()
	var path: Array[int] = [] # directions taken, popped to backtrack
	var max_steps = 50000
	var steps = 0
	var failed = false

	while steps < max_steps:
		steps += 1
		var dir = get_unvisited_direction(dungeon)
		if dir != null:
			if !dungeon.move_direction(dir):
				print("Failed to move forward ", dir, " at ", dungeon.current_location)
				failed = true
				break
			path.append(dir)
			continue

		if path.is_empty():
			break # back at start with nothing unvisited: the dungeon ran out

		var back = Dungeon.get_opposite_dir(path.pop_back())
		if !dungeon.move_direction(back):
			print("Failed to backtrack ", back, " at ", dungeon.current_location)
			failed = true
			break

	var ran_out = steps < max_steps && !failed
	print("Steps: ", steps, " corridors: ", dungeon.map.size(), " untravelled: ", count_untravelled(dungeon))
	if ran_out:
		print("Dungeon ran out of places to explore!")

	# Walk back to start so backtracking itself gets verified.
	while !path.is_empty():
		var back = Dungeon.get_opposite_dir(path.pop_back())
		if !dungeon.move_direction(back):
			print("Failed to backtrack ", back, " at ", dungeon.current_location)
			failed = true
			break

	var problems = find_inconsistencies(dungeon)
	for p in problems.slice(0, 20):
		print("  ", p)
	print("Inconsistencies: ", problems.size())

	assert_eq(failed, false)
	assert_eq(ran_out, false)
	assert_eq(dungeon.current_location, Vector2i.ZERO)
	assert_eq(problems.size(), 0)
	dungeon.dump_map(10)
	print(dungeon.frontiers)
	print("DEAD ENDS:" + str(1.0 * dungeon.dead_ends/dungeon.explored_num))


# --- Exit corridor ---

func test_exit_is_south_of_start_and_only_leads_back() -> void:
	var dungeon := Dungeon.new()
	var exit_corridor: Corridor = dungeon.map.get(Dungeon.EXIT_LOCATION)
	assert_true(exit_corridor.is_exit)
	assert_eq(Dungeon.EXIT_LOCATION, Vector2i(0, 1))
	assert_true(dungeon.move_direction(Direction.SOUTH))
	assert_true(dungeon.is_at_exit())
	assert_eq(exit_corridor.open_directions, [Direction.NORTH] as Array[Direction], "no corridors come out of it")
	assert_false(dungeon.map.has(Vector2i(0, 2)))


func test_nothing_connects_into_the_exit_later() -> void:
	seed(5)
	var dungeon := Dungeon.new()
	# wander around the start a lot; neighbours of the exit must never open into it
	for i in 400:
		var dirs := dungeon.get_current_corridor().open_directions.duplicate()
		dungeon.move_direction(dirs.pick_random())
	var exit_corridor: Corridor = dungeon.map.get(Dungeon.EXIT_LOCATION)
	assert_eq(exit_corridor.open_directions, [Direction.NORTH] as Array[Direction])
	for dir in [Direction.EAST, Direction.SOUTH, Direction.WEST]:
		var neighbour: Corridor = dungeon.map.get(Dungeon.EXIT_LOCATION + Dungeon.directions[dir])
		if neighbour != null:
			assert_false(neighbour.can_move(Dungeon.get_opposite_dir(dir)))
