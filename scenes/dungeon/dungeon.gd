enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

class Corridor:
	var open_directions: Array[Direction] = []
	var did_travel = false
	## The way out, just south of the start. Never grows new corridors
	var is_exit = false

	func can_move(dir: Direction):
		return open_directions.has(dir)

	func open_dir(dir: Direction):
		if open_directions.has(dir): return
		open_directions.append(dir)

## NORTH <-> SOUTH, EAST <-> WEST. Opposites are always 2 apart in the enum.

class Dungeon:
	var map: Dictionary[Vector2i, Corridor] = {}
	var current_location: Vector2i = Vector2i.ZERO
	static var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var frontiers = 0
	var no_dead_end_radius = 20
	var explored_num = 0
	var dead_ends = 0
	var facing: Direction = Direction.NORTH
	
	signal moved(location: Vector2i, facing: Direction)
	
	func _init() -> void:
		var initial_corridor = Corridor.new()
		map.set(Vector2i.ZERO, initial_corridor)
		# self._travel_to(Vector2i.ZERO)
		self._setup_first_room()

	static func get_opposite_dir(direction: Direction) -> Direction:
		return ((direction + 2) % 4) as Direction

	func face(dir: Direction):
		facing = dir
		moved.emit(current_location, facing)

	func turn_left():
		face(posmod(facing - 1, 4))

	func turn_right():
		face(posmod(facing + 1, 4))

	func move_forward():
		move_direction(facing)

	func has_corridor(loc: Vector2i):
		return map.has(loc)

	func dir_to_vec(dir: Direction):
		return directions[dir]

	func apply_direction(vec: Vector2i, dir: Direction):
		return vec + dir_to_vec(dir)

	func move_direction(dir: Direction):
		var new_pos = self.current_location + self.directions[dir]
		if new_pos == null:
			return false
			
		if !can_move_direction(dir):
			return false

		return self._travel_to(new_pos)

	func can_move_direction(dir: Direction):		
		var corridor = self.map.get(self.current_location)
		return corridor.can_move(dir)

	func get_current_corridor() -> Corridor:
		return map.get(self.current_location)

	func get_adjacent_corridor(dir: Direction):
		return self.map.get(self.apply_direction(self.current_location, dir))
	
	func _setup_first_room():
		if current_location != Vector2i.ZERO: return

		var loc = Vector2i.ZERO
		var corridor: Corridor = map.get(loc)

		for i in range(4):
			var new_vec = apply_direction(loc, i) # TODO: we compute this twice...
			var new_corridor = Corridor.new()
			corridor.open_dir(i) # open direction in current corridor
			new_corridor.open_dir(Dungeon.get_opposite_dir(i)) # open opposite dir in new corridor
			map.set(new_vec, new_corridor)
			frontiers += 1

		# the corridor behind the start is the exit
		map.get(EXIT_LOCATION).is_exit = true

	## South of the start (Vector2i.DOWN is south)
	const EXIT_LOCATION := Vector2i(0, 1)

	func is_at_exit() -> bool:
		var corridor: Corridor = map.get(current_location)
		return corridor != null and corridor.is_exit

	func _travel_to(loc: Vector2i):
		# TODO: maybe store an adjacency matrix or similar
		var corridor: Corridor = map.get(loc)
		var dead_end_allowed = loc.distance_to(Vector2i.ZERO) > no_dead_end_radius # only allow a dead end if we have places to go
		if (corridor == null): return false
		

		self.current_location = loc

		if corridor.did_travel:
			moved.emit(current_location, facing)
			return true

		# create corridors around the corridor! TODO: check these, makes me feel iffy
		var need_slots: Array[Direction] = []

		for i in range(Direction.size()):
			var dir: Direction = i
			var new_vec = apply_direction(loc, dir)
			# the exit is a dead end: nothing branches off it
			if !has_corridor(new_vec) and !corridor.is_exit:
				need_slots.append(dir)
		need_slots.shuffle()
		
		# pick some slots and add adjacent cells
		if !need_slots.is_empty():
			# generate random between 0 (dead end) or 1 through 4 (all directions open)
			var rnd = randi_range(0 if dead_end_allowed else 1, need_slots.size())

			#if rnd == 0 && randf() < 0.25:
				#rnd = randi_range(1, need_slots.size())

			if rnd == 0:
				dead_ends += 1
			
			for i in range(rnd):
				var dir: Direction = need_slots[i]
				var new_vec = apply_direction(loc, dir) # TODO: we compute this twice...
				var new_corridor = Corridor.new()
				corridor.open_dir(dir) # open direction in current corridor
				new_corridor.open_dir(Dungeon.get_opposite_dir(dir)) # open opposite dir in new corridor
				map.set(new_vec, new_corridor)
				frontiers += 1
				
				# potentially put a monster here
				
		
		corridor.did_travel = true
		frontiers -= 1
		explored_num += 1
		no_dead_end_radius = 20 + 0.5 * sqrt(explored_num);

		moved.emit(current_location, facing)

		return true

	func dump_current(radius: int = 4):
		var corridor: Corridor = map.get(current_location)
		print("--- Current corridor " + str(current_location) + " (travelled: " + str(corridor.did_travel) + ") ---")
		for dir in Direction.values():
			var state = "wall"
			if corridor.can_move(dir):
				var neighbour: Corridor = map.get(apply_direction(current_location, dir))
				state = "open (visited)" if neighbour != null and neighbour.did_travel else "open"
			print("  " + Direction.find_key(dir).rpad(5) + " : " + state)

		dump_map(radius)

	## Map of corridors within `radius` of the current one.
	## @ = you, S = start (0, 0), o = travelled, + = not travelled yet, blank = nothing
	## - and | = open link, ? = only one side says it's open
	func dump_map(radius: int = 4):
		for y in range(current_location.y - radius, current_location.y + radius + 1):
			var row = ""
			var below = ""
			for x in range(current_location.x - radius, current_location.x + radius + 1):
				var loc = Vector2i(x, y)
				var c: Corridor = map.get(loc)
				if loc == current_location: row += "@"
				elif loc == Vector2i.ZERO: row += "S"
				elif c == null: row += " "
				elif c.did_travel: row += "o"
				else: row += "+"
				row += _link_char(loc, Direction.EAST, "-")
				below += _link_char(loc, Direction.SOUTH, "|") + " "
			print("  : " + row)
			if y < current_location.y + radius:
				print("  : " + below)

	func _link_char(loc: Vector2i, dir: Direction, open_char: String) -> String:
		var a: Corridor = map.get(loc)
		var b: Corridor = map.get(apply_direction(loc, dir))
		var a_open = a != null and a.can_move(dir)
		var b_open = b != null and b.can_move(Dungeon.get_opposite_dir(dir))
		if a_open and b_open: return open_char
		if a_open or b_open: return "?"
		return " "
