extends Control

## Inventory screen. Everything inside Frame is laid out in the art's own
## 320x180 pixels, and Frame is scaled up by a whole number to fit the window.

signal closed

const ItemSlot = preload("res://scenes/inventory/item_slot.gd")

const ART_SIZE := Vector2(320, 180)
const SLOT_SIZE := Vector2(27, 27)
const SLOT_STEP := 29
## Top-left of the first slot in each grid, in art pixels
const BAG_ORIGIN := Vector2(109, 4)
const BAG_COLUMNS := 4
const EQUIP_ORIGIN := Vector2(11, 119)
const EQUIP_COLUMNS := 3
## The box in the top-left of the art, where the character is drawn
const PORTRAIT_RECT := Rect2(5, 6, 97, 65)

const EMPTY_ICONS := {
	Item.Slot.HAT: preload("res://scenes/inventory/art/empty_hat.png"),
	Item.Slot.COLLAR: preload("res://scenes/inventory/art/empty_collar.png"),
	Item.Slot.ARMOR: preload("res://scenes/inventory/art/empty_armor.png"),
	Item.Slot.WEAPON: preload("res://scenes/inventory/art/empty_weapon.png"),
	Item.Slot.TRINKET: preload("res://scenes/inventory/art/empty_trinket.png"),
}

@export var frame: Control
@export var stats_label: Label
@export var item_name_label: Label
@export var item_info_label: Label

var player: Player
var bag_slots: Array = []
var equip_slots: Array = []
## Which slot is selected: "bag" or "equip", and its index
var selected_kind := ""
var selected_index := -1
var portrait: TextureRect
## "+" buttons next to HP / Attack / Agility, shown while there are free stat points
var stat_buttons: Array[Button] = []
## Throws the selected item away. Needs a second click to confirm
var delete_button: Button
var delete_armed := false
## In the empty strip under the portrait box
const DELETE_RECT := Rect2(62, 77, 38, 12)
## Which line of the stats text each stat is on (line 0 is the level)
const STAT_LINES := {Player.Stat.HP: 1, Player.Stat.ATTACK: 2, Player.Stat.AGILITY: 3}
const STAT_BUTTON_SIZE := Vector2(10, 10)


func _ready() -> void:
	if player == null:
		player = Game.player

	for i in Inventory.BAG_SIZE:
		var slot := _make_slot(BAG_ORIGIN, BAG_COLUMNS, i)
		slot.pressed.connect(_on_bag_pressed.bind(i))
		bag_slots.append(slot)
	for i in Inventory.EQUIP_LAYOUT.size():
		var slot := _make_slot(EQUIP_ORIGIN, EQUIP_COLUMNS, i)
		slot.empty_icon = EMPTY_ICONS[Inventory.EQUIP_LAYOUT[i]]
		slot.pressed.connect(_on_equip_pressed.bind(i))
		equip_slots.append(slot)

	portrait = TextureRect.new()
	portrait.position = PORTRAIT_RECT.position
	portrait.size = PORTRAIT_RECT.size
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(portrait)

	for stat in Player.Stat.values():
		var button := Button.new()
		button.text = "+"
		button.add_theme_font_size_override("font_size", 6)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		for state in ["normal", "hover", "pressed"]:
			var style := StyleBoxFlat.new()
			style.bg_color = {"normal": Color(0.42, 0.36, 0.3), "hover": Color(0.55, 0.47, 0.38), "pressed": Color(0.3, 0.26, 0.22)}[state]
			style.set_corner_radius_all(2)
			style.set_content_margin_all(0)
			button.add_theme_stylebox_override(state, style)
		button.size = STAT_BUTTON_SIZE
		button.custom_minimum_size = STAT_BUTTON_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_stat_button_pressed.bind(stat))
		frame.add_child(button)
		stat_buttons.append(button)

	delete_button = Button.new()
	delete_button.position = DELETE_RECT.position
	delete_button.size = DELETE_RECT.size
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.add_theme_font_size_override("font_size", 7)
	# black and white with square corners, like the rest of the game's UI
	for state in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.85, 0.85, 0.85) if state == "hover" else Color.WHITE
		style.border_color = Color.BLACK
		style.set_border_width_all(1)
		style.set_content_margin_all(0)
		delete_button.add_theme_stylebox_override(state, style)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		delete_button.add_theme_color_override(c, Color.BLACK)
	delete_button.pressed.connect(_on_delete_pressed)
	delete_button.visible = false
	frame.add_child(delete_button)

	# item descriptions get a smaller font so long ones fit the panel
	if item_info_label.label_settings:
		var small := item_info_label.label_settings.duplicate()
		small.font_size = 6
		small.line_spacing = -1
		item_info_label.label_settings = small
	item_info_label.clip_text = true

	player.inventory.changed.connect(_refresh)
	resized.connect(_fit_frame)
	_fit_frame()
	_refresh()


func _make_slot(origin: Vector2, columns: int, index: int) -> ItemSlot:
	var slot := ItemSlot.new()
	slot.position = origin + Vector2(index % columns, index / columns) * SLOT_STEP
	slot.size = SLOT_SIZE
	frame.add_child(slot)
	return slot


func _fit_frame() -> void:
	var scale_factor := maxf(floorf(minf(size.x / ART_SIZE.x, size.y / ART_SIZE.y)), 1.0)
	frame.scale = Vector2.ONE * scale_factor
	frame.position = ((size - ART_SIZE * scale_factor) / 2).floor()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func close() -> void:
	closed.emit()
	queue_free()


## Click selects an item; clicking it again uses or equips it
func _on_bag_pressed(index: int) -> void:
	var item := player.inventory.bag[index]
	if selected_kind == "bag" and selected_index == index and item != null:
		if item.consumable:
			item_info_label.text = player.use_item(index)
			_select("", -1, false)
			_refresh_stats()
			return
		if item.is_equippable():
			if not player.equip(index):
				item_info_label.text = "You're not human enough to wear this yet."
				return
			_select("", -1)
			return
	_select("bag", index)


## Click selects an equipped item; clicking it again takes it off
func _on_equip_pressed(index: int) -> void:
	var item := player.inventory.equipped[index]
	if selected_kind == "equip" and selected_index == index and item != null:
		if not player.inventory.unequip(index):
			item_info_label.text = "Your bag is full."
			return
		_select("", -1)
		return
	_select("equip", index)


func _select(kind: String, index: int, show_info := true) -> void:
	selected_kind = kind
	selected_index = index
	for i in bag_slots.size():
		bag_slots[i].set_selected(kind == "bag" and i == index)
	for i in equip_slots.size():
		equip_slots[i].set_selected(kind == "equip" and i == index)
	delete_armed = false
	_update_delete_button()
	if show_info:
		_show_item_info()


func _update_delete_button() -> void:
	delete_button.visible = _get_selected_item() != null
	delete_button.text = "Sure?" if delete_armed else "Delete"
	delete_button.size = DELETE_RECT.size


## First click asks "Sure?", the second throws the item away for good
func _on_delete_pressed() -> void:
	var item := _get_selected_item()
	if item == null:
		return
	if not delete_armed:
		delete_armed = true
		_update_delete_button()
		return
	if selected_kind == "bag":
		player.inventory.remove_at(selected_index)
	else:
		player.inventory.remove_equipped(selected_index)
	_select("", -1, false)
	item_name_label.text = ""
	item_info_label.text = "You threw away the %s." % item.display_name


func _get_selected_item() -> Item:
	if selected_kind == "bag":
		return player.inventory.bag[selected_index]
	if selected_kind == "equip":
		return player.inventory.equipped[selected_index]
	return null


func _show_item_info() -> void:
	var item := _get_selected_item()
	if item == null:
		item_name_label.text = ""
		item_info_label.text = ""
		return

	item_name_label.text = item.display_name
	var lines: PackedStringArray = [item.get_rarity_name(), item.description]
	var bonuses := item.get_bonus_text()
	if bonuses != "":
		lines.append(bonuses)
	if selected_kind == "equip":
		lines.append("Click again to take off")
	elif item.consumable:
		lines.append("Click again to use")
	elif item.is_equippable() and not player.can_equip(item):
		lines.append("Needs a more human form")
	elif item.is_equippable():
		lines.append("Click again to equip")
	item_info_label.text = "\n".join(lines)


func _refresh() -> void:
	for i in bag_slots.size():
		bag_slots[i].set_item(player.inventory.bag[i])
	for i in equip_slots.size():
		equip_slots[i].set_item(player.inventory.equipped[i])
	portrait.texture = player.get_sprite()
	_refresh_stats()


func _refresh_stats() -> void:
	var lines: PackedStringArray = [
		"Lv %d  XP %d/%d" % [player.level, player.xp, player.get_xp_to_next_level()],
		"HP %d/%d" % [player.hp, player.get_max_hp()],
		"Attack %d" % player.get_attack_power(),
		"Agility %d" % player.get_agility(),
	]
	# gear stats share lines (two per line) so a fully kitted cat still fits the panel
	var extras: PackedStringArray = []
	if player.get_damage_per_turn() > 0:
		extras.append("DoT %d" % player.get_damage_per_turn())
	if player.get_thorns_damage() > 0:
		extras.append("Thorns %d" % player.get_thorns_damage())
	if player.get_regen_per_turn() > 0:
		extras.append("Regen %d" % player.get_regen_per_turn())
	for i in range(0, extras.size(), 2):
		lines.append("  ".join(extras.slice(i, i + 2)))
	if player.stat_points > 0:
		lines.append("Points: %d" % player.stat_points)
	stats_label.text = "\n".join(lines)
	_place_stat_buttons()


## Lines the "+" buttons up with their stat's line, at the right edge of the panel
func _place_stat_buttons() -> void:
	var line_height := float(stats_label.get_line_height())
	if stats_label.label_settings:
		line_height += stats_label.label_settings.line_spacing
	for stat in stat_buttons.size():
		var button := stat_buttons[stat]
		button.visible = player.stat_points > 0
		button.size = STAT_BUTTON_SIZE
		var line: int = STAT_LINES[stat]
		var line_top := stats_label.position.y + line * line_height
		button.position = Vector2(
			stats_label.position.x + stats_label.size.x - STAT_BUTTON_SIZE.x,
			line_top + (line_height - STAT_BUTTON_SIZE.y) / 2)


func _on_stat_button_pressed(stat: Player.Stat) -> void:
	player.spend_stat_point(stat)
	_refresh_stats()
