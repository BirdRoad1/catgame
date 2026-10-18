extends Node

## Opens the inventory on top of the dungeon with the toggle_inventory key (I)
## or the Inventory button. Also shows the character in the bottom-left corner.

const InventoryScene = preload("res://scenes/inventory/inventory.tscn")

## Hidden and disabled while the inventory is open
@export var movement_controller: Node
## So the inventory can't be opened mid-fight
@export var encounter_controller: Node

var is_open := false
## The character's picture and the Inventory button. Shown only while walking around
var hud: Control
var portrait: TextureRect

const INVENTORY_BUTTON_TEXTURE := preload("res://scenes/dungeon/art/btns/inventory_button.png")
## Art is pixel art at 1x, so it's scaled up by this much on screen
const HUD_SCALE := 3.0


func _ready() -> void:
	_build_hud()
	# the HUD hides whenever walking does (battles, chests, inventory, passing out)
	movement_controller.visibility_changed.connect(_update_hud)
	Game.player.form_changed.connect(_on_form_changed)


func _exit_tree() -> void:
	if Game.player.form_changed.is_connected(_on_form_changed):
		Game.player.form_changed.disconnect(_on_form_changed)


func _build_hud() -> void:
	hud = HBoxContainer.new()
	hud.alignment = BoxContainer.ALIGNMENT_BEGIN
	hud.add_theme_constant_override("separation", 16)
	hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hud.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud.offset_left = 20
	hud.offset_bottom = -20
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE

	portrait = TextureRect.new()
	portrait.texture = Game.player.get_sprite()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(97, 65) * HUD_SCALE
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(portrait)

	var button := TextureButton.new()
	button.texture_normal = INVENTORY_BUTTON_TEXTURE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = INVENTORY_BUTTON_TEXTURE.get_size() * HUD_SCALE * 0.5
	button.size_flags_vertical = Control.SIZE_SHRINK_END
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.pressed.connect(_on_inventory_button_pressed)
	hud.add_child(button)

	owner.add_child.call_deferred(hud)


func _update_hud() -> void:
	hud.visible = movement_controller.visible


func _on_form_changed(_form) -> void:
	portrait.texture = Game.player.get_sprite()


func _on_inventory_button_pressed() -> void:
	if not is_open and not encounter_controller.is_busy():
		open()


func _unhandled_input(event: InputEvent) -> void:
	if is_open or encounter_controller.is_busy():
		return
	if event.is_action_pressed("toggle_inventory"):
		get_viewport().set_input_as_handled()
		open()


func open() -> void:
	is_open = true
	movement_controller.process_mode = Node.PROCESS_MODE_DISABLED
	movement_controller.visible = false

	var inventory = InventoryScene.instantiate()
	inventory.player = Game.player
	inventory.closed.connect(_on_closed)
	owner.add_child(inventory)


func _on_closed() -> void:
	is_open = false
	movement_controller.process_mode = Node.PROCESS_MODE_INHERIT
	movement_controller.visible = true
