extends Node2D
class_name DungeonSystem

enum Direction {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

## NORTH <-> SOUTH, EAST <-> WEST. Opposites are always 2 apart in the enum.
static func get_opposite_dir(direction: Direction) -> Direction:
	return ((direction + 2) % 4) as Direction

class LinkedCorridor:
	var directions: Array[LinkedCorridor] = [null, null, null, null]
	var did_travel = false

	func _init(init_directions: Array[LinkedCorridor] = [null, null, null, null]):
		self.directions = init_directions

	func before_travel_to(dead_end_allowed: bool = true):
		if (self.did_travel): return false # already travelled/generated
		self.did_travel = true
		
		
		# Probably a one liner for this
		var open_indices = []
		for i in self.directions.size():
			var direction = self.directions[i]
			if direction == null:
				open_indices.append(i)
		open_indices.shuffle()
		
		#var full_directions = init_directions.filter(func(element): return element != null).size()
		#var remaining_possible = 4 - full_directions;
		var remaining_possible = open_indices.size()
		
		# generate random between 0 (dead end) or 1 through 4 (all directions open)
		var rnd = randi_range(0 if dead_end_allowed else 1, 4)
		
		# limit openings to the amount possible
		var actual = min(rnd, remaining_possible)
		
		print("Going to fill " + str(actual) + " directions!!!")
		for i in range(actual):
			var dir = open_indices[i]
			var arr: Array[LinkedCorridor] = [null, null, null, null]
			arr[DungeonSystem.get_opposite_dir(dir)] = self
			self.directions[dir] = LinkedCorridor.new(arr)
		
		return true
		
class Dungeon:
	var current_corridor = LinkedCorridor.new()
	
	func init():
		current_corridor.before_travel_to(false)
		print("Loaded current corridor!")
	
	func go_direction(direction: Direction):
		var new_corridor = self.current_corridor.directions[direction]
		print("CURRENT: " + str(self.current_corridor.directions))
		if new_corridor == null:
			print("Invalid move!")
			return false # invalid move
		new_corridor.before_travel_to(true)
		current_corridor = new_corridor
		return true

	func dump_current():
		var corridor = self.current_corridor
		print("--- Current corridor (travelled: " + str(corridor.did_travel) + ") ---")
		for dir in Direction.values():
			var neighbour = corridor.directions[dir]
			var state = "wall"
			if neighbour != null:
				state = "open (visited)" if neighbour.did_travel else "open"
			print("  " + Direction.find_key(dir).rpad(5) + " : " + state)

		# Little map: # = wall, . = open, @ = you
		var n = "." if corridor.directions[Direction.NORTH] != null else "#"
		var e = "." if corridor.directions[Direction.EAST] != null else "#"
		var s = "." if corridor.directions[Direction.SOUTH] != null else "#"
		var w = "." if corridor.directions[Direction.WEST] != null else "#"
		print("   # " + n + " #")
		print("   " + w + " @ " + e)
		print("   # " + s + " #")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dungeon = Dungeon.new()
	dungeon.init()
	# Generate the current corridor every time the player moves, remember old corridors 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
