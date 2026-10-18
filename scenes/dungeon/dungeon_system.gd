extends Control

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction

@export var corridor_img: TextureRect
@export var coords: Label
@export var minimap_draw: Control

var dungeon = Dungeon.new()

func get_relevant_directions():
	var left = posmod(dungeon.facing - 1, 4)
	var center = dungeon.facing
	var right = posmod(dungeon.facing + 1, 4)

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

func _on_move(_pos, _facing):
	corridor_img.texture = get_relevant_image()
	_update_coords()


func _update_coords() -> void:
	coords.text = "(" + str(dungeon.current_location.x) + ", " + str(dungeon.current_location.y) + ") Facing: " + Direction.keys()[dungeon.facing]


func _ready() -> void:
	corridor_img.texture = get_relevant_image()

	dungeon.moved.connect(_on_move)
	coords.visible = Game.show_debug
	Game.debug_toggled.connect(_on_debug_toggled)

	_update_coords()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_debug_toggled(debug_visible: bool) -> void:
	coords.visible = debug_visible


func _exit_tree() -> void:
	if Game.debug_toggled.is_connected(_on_debug_toggled):
		Game.debug_toggled.disconnect(_on_debug_toggled)
