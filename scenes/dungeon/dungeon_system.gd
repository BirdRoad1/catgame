extends Control

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction

@export var corridor_img: TextureRect
@export var coords: Label
@export var minimap_draw: Control

var facing: Direction = Direction.NORTH
var dungeon = Dungeon.new()

func face(dir: Direction):
	self.facing = dir

func turn_left():
	face(posmod(facing - 1, 4))

func turn_right():
	face(posmod(facing + 1, 4))

func get_relevant_directions():
	var left = posmod(facing - 1, 4)
	var center = facing
	var right = posmod(facing + 1, 4)

	print("LEFT:")
	print(left)
	print(dungeon.can_move_direction(left))
	return [dungeon.can_move_direction(left), dungeon.can_move_direction(center), dungeon.can_move_direction(right)]

# Based on the direction, 
func get_relevant_image() -> Texture2D:
	var dirs = get_relevant_directions()
	print(dirs)
	var l = 'y' if dirs[0] else 'n'
	var c = 'y' if dirs[1] else 'n'
	var r = 'y' if dirs[2] else 'n'

	var title = l + c + r + '.png'

	return load("res://scenes/dungeon/art/corrodor/" + title) as Texture2D


func get_unvisited_direction():
	for direction in range(4):
		var adjacent_corridor = dungeon.get_adjacent_corridor(direction)
		if dungeon.can_move_direction(direction) && adjacent_corridor != null && !adjacent_corridor.did_travel:
			return direction
	return null


# Called when the node enters the scene tree for the first time.
## Depth-first backtracking walk: unvisited corridors first, retrace the path when stuck.
func _ready() -> void:
	var path: Array[int] = [] # directions taken, popped to backtrack
	corridor_img.texture = get_relevant_image()

	for i in 1000:

		var dir = get_unvisited_direction()
		if dir != null:
			path.append(dir)
		elif path.is_empty():
			break # back at start with nothing unvisited
		else:
			dir = Dungeon.get_opposite_dir(path.pop_back())

		await get_tree().create_timer(1.0/3).timeout
		face(dir)
		minimap_draw.refresh(dungeon, facing)
		await get_tree().create_timer(1.0/3).timeout
		dungeon.move_direction(dir)
		minimap_draw.refresh(dungeon, facing)
		coords.text = "(" + str(dungeon.current_location.x) + ", " + str(dungeon.current_location.y) + ") Facing: " + Direction.keys()[facing] 
		corridor_img.texture = get_relevant_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
