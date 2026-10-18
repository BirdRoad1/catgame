extends Control

## One square in the inventory. Shows an item, or the empty-slot icon if there is none.

signal pressed

const LETTER_COLOR := Color(0.25, 0.22, 0.2)
const SELECTED_COLOR := Color(0.9, 0.6, 0.15)

var item: Item
var empty_icon: Texture2D
var selected := false


func set_item(p_item: Item) -> void:
	item = p_item
	queue_redraw()


func set_selected(p_selected: bool) -> void:
	selected = p_selected
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()
		accept_event()


func _draw() -> void:
	if item != null:
		if item.icon != null:
			draw_texture_rect(item.icon, Rect2(Vector2.ZERO, size), false)
		else:
			# no art yet: show the first letter of the name
			var font := get_theme_default_font()
			var font_size := 16
			var letter := item.display_name.left(1)
			var text_size := font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			var pos := Vector2((size.x - text_size.x) / 2, (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) / 2)
			draw_string(font, pos, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LETTER_COLOR)
	elif empty_icon != null:
		draw_texture_rect(empty_icon, Rect2(Vector2.ZERO, size), false)

	if selected:
		draw_rect(Rect2(Vector2.ZERO, size).grow(-0.5), SELECTED_COLOR, false, 1.0)
