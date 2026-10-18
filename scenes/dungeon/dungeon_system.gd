extends Control

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction

@export var corridor_img: TextureRect
@export var coords: Label
@export var minimap_draw: Control

var dungeon = Dungeon.new()
const HOME_SCENE := "res://scenes/home/catroom/catroom.tscn"
## Big button in the middle of the exit corridor. Leaving here costs nothing
var exit_button: Button

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
	# the exit only opens back north, so facing away from it shows the dead-end
	# wall; that's where the button is
	exit_button.visible = dungeon.is_at_exit() and dungeon.facing != Direction.NORTH and not dungeon.can_move_direction(dungeon.facing)


func _update_coords() -> void:
	coords.text = "(" + str(dungeon.current_location.x) + ", " + str(dungeon.current_location.y) + ") Facing: " + Direction.keys()[dungeon.facing]


func _ready() -> void:
	corridor_img.texture = get_relevant_image()

	dungeon.moved.connect(_on_move)
	_build_exit_button()
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


func _build_exit_button() -> void:
	exit_button = Button.new()
	exit_button.text = "EXIT"
	exit_button.add_theme_font_size_override("font_size", 64)
	# black and white with square corners, like the rest of the game's art
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_content_margin_all(28)
	style.border_color = Color.BLACK
	style.set_border_width_all(2)
	var hover := style.duplicate()
	hover.bg_color = Color(0.85, 0.85, 0.85)
	exit_button.add_theme_stylebox_override("normal", style)
	exit_button.add_theme_stylebox_override("hover", hover)
	exit_button.add_theme_stylebox_override("pressed", style)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		exit_button.add_theme_color_override(c, Color.BLACK)
	exit_button.custom_minimum_size = Vector2(320, 0)
	exit_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	exit_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	exit_button.grow_vertical = Control.GROW_DIRECTION_BOTH
	exit_button.visible = false
	exit_button.pressed.connect(_on_exit_pressed)
	# right above the corridor art, so menus, fights and the inventory still cover it
	add_child(exit_button)
	move_child(exit_button, corridor_img.get_index() + 1)


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)
