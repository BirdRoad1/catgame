extends Control

## Emitted when the fight is over. result has "won" and "escaped".
signal finished(result: Dictionary)
## Emitted when the player does something that takes a turn (attack, escape...)
signal turn_taken

const TURN_DELAY := 0.8
const AttackBarScene = preload("res://scenes/battle/attack_bar/attack_bar.tscn")
const InventoryScene = preload("res://scenes/inventory/inventory.tscn")

## Set these before adding the scene to the tree
var monster: Monster
var player: Player

@export var monster_art: TextureRect
@export var monster_label: Label
@export var monster_hp_bar: HpBar
@export var player_label: Label
@export var player_hp_bar: HpBar
@export var log_label: Label
@export var main_menu: Control
@export var fight_menu: Control
@export var fight_btn: Button
@export var escape_btn: Button
@export var attack_btn: Button
@export var back_btn: Button

var busy := false
@onready var inventory_btn: Button = $Menus/MainMenu/Inventory
## The inventory screen while it's open, and the last item used from it
var inventory_screen: Control
var used_item_message := ""
## Extra text for the monster's turn, e.g. thorns damage
var extra_log := ""
## Set when the player runs out of turns mid-fight: they pass out once the current round is over
var stop_after_round := false


func _ready() -> void:
	# lets the scene be run on its own (F6) for testing
	if monster == null:
		monster = Slime.new()
	if player == null:
		player = Game.player

	monster_art.texture = monster.texture

	fight_btn.pressed.connect(_show_fight_menu)
	back_btn.pressed.connect(_show_main_menu)
	attack_btn.pressed.connect(_attack)
	escape_btn.pressed.connect(_escape)
	inventory_btn.pressed.connect(_open_inventory)

	_show_main_menu()
	_update_labels()
	log_label.text = "A %s appears!" % monster.display_name


## The inventory key opens the bag mid-fight too (the bag closes itself with it)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory") and not busy and inventory_screen == null:
		get_viewport().set_input_as_handled()
		_open_inventory()


## Looking and changing gear is free; using an item costs the turn
func _open_inventory() -> void:
	if busy or inventory_screen != null:
		return
	_set_buttons_enabled(false)
	used_item_message = ""
	player.item_used.connect(_on_item_used)
	inventory_screen = InventoryScene.instantiate()
	inventory_screen.player = player
	inventory_screen.closed.connect(_on_inventory_closed)
	add_child(inventory_screen)


func _on_item_used(message: String) -> void:
	used_item_message = message


func _on_inventory_closed() -> void:
	player.item_used.disconnect(_on_item_used)
	inventory_screen = null
	_update_labels()
	if used_item_message.is_empty():
		_set_buttons_enabled(true)
		return
	turn_taken.emit()
	log_label.text = used_item_message
	await _wait()
	await _monster_turn()


func _show_main_menu() -> void:
	main_menu.visible = true
	fight_menu.visible = false


func _show_fight_menu() -> void:
	main_menu.visible = false
	fight_menu.visible = true


func _update_labels() -> void:
	monster_label.text = "%s  %d/%d" % [monster.display_name, monster.hp, monster.max_hp]
	monster_hp_bar.set_hp(monster.hp, monster.max_hp)
	player_label.text = "HP  %d/%d" % [player.hp, player.get_max_hp()]
	player_hp_bar.set_hp(player.hp, player.get_max_hp())


func _set_buttons_enabled(enabled: bool) -> void:
	busy = not enabled
	for btn in [fight_btn, inventory_btn, escape_btn, attack_btn, back_btn]:
		btn.disabled = not enabled


func _attack() -> void:
	if busy:
		return
	_set_buttons_enabled(false)
	turn_taken.emit()

	var bar = AttackBarScene.instantiate()
	bar.sweep_time = bar.sweep_time_for(monster.level, player.level)
	add_child(bar)
	var accuracy: float = await bar.finished

	var damage := _damage_for_accuracy(accuracy)
	monster.hp = max(monster.hp - damage, 0)
	if damage == 0:
		log_label.text = "You missed!"
	else:
		log_label.text = "You hit the %s for %d!" % [monster.display_name, damage]
		if accuracy >= 1.0 - PERFECT_HIT_MARGIN:
			log_label.text = "Perfect hit! " + log_label.text
	_update_labels()
	await _wait()

	if monster.hp == 0:
		await _win()
		return

	await _monster_turn()


## Hits within this much of a perfect attack bar do bonus damage
const PERFECT_HIT_MARGIN := 0.05
const PERFECT_HIT_MULTIPLIER := 1.2


## How much an attack does for a given attack bar result (1.0 = perfect)
func _damage_for_accuracy(accuracy: float) -> int:
	var damage := player.get_attack_power() * accuracy
	if accuracy >= 1.0 - PERFECT_HIT_MARGIN:
		damage *= PERFECT_HIT_MULTIPLIER
	return roundi(damage)


func _escape() -> void:
	if busy:
		return
	_set_buttons_enabled(false)
	turn_taken.emit()

	if monster.level - player.level >= Player.NO_ESCAPE_LEVEL_GAP:
		log_label.text = "The %s is far too strong to escape from!" % monster.display_name
		await _wait()
		await _monster_turn()
		return

	if randf() < player.get_escape_chance(monster):
		log_label.text = "You got away!"
		await _wait()
		_finish(false, true)
		return

	log_label.text = "Couldn't escape!"
	await _wait()
	await _monster_turn()


func _monster_turn() -> void:
	# lingering damage from gear (fire, poison...) hits before the monster acts
	var lingering := player.get_damage_per_turn()
	if lingering > 0:
		monster.hp = max(monster.hp - lingering, 0)
		log_label.text = "The %s takes %d lingering damage!" % [monster.display_name, lingering]
		_update_labels()
		await _wait()
		if monster.hp == 0:
			await _win()
			return

	extra_log = ""
	monster.regen_sp()
	var skill := monster.choose_skill(self)
	log_label.text = monster.use_skill(skill, self) + extra_log
	_update_labels()

	if monster.hp == 0:
		await _wait()
		await _win()
		return

	if player.hp == 0:
		await _wait()
		log_label.text = "You were defeated..."
		await _wait()
		_finish(false, false)
		return

	if stop_after_round:
		await _wait()
		log_label.text = "You're too exhausted to keep fighting..."
		await _wait()
		_finish(false, false)
		return

	_set_buttons_enabled(true)
	_show_main_menu()


## Called by monster skills. Returns the damage actually taken (0 if dodged)
func damage_player(amount: int) -> int:
	if randf() < player.get_dodge_chance():
		return 0
	player.take_damage(amount)

	var thorns := player.get_thorns_damage()
	if thorns > 0:
		monster.hp = max(monster.hp - thorns, 0)
		extra_log = " Your armor deals %d back!" % thorns
	return amount


func _win() -> void:
	log_label.text = "The %s is defeated!" % monster.display_name
	await _wait()
	var levels := player.gain_xp(monster.xp_reward)
	log_label.text = "You gained %d XP!" % monster.xp_reward
	if levels > 0:
		log_label.text += " Level up! You're now level %d." % player.level
	await _wait()
	var drop := LootTable.roll_drop(monster)
	if drop != null:
		log_label.text = "The %s dropped a %s %s!" % [monster.display_name, drop.get_rarity_name(), drop.display_name]
		if not player.inventory.add(drop):
			log_label.text += " But your bag is full, so you leave it behind."
		await _wait()
	_finish(true, false)


func _wait() -> void:
	await get_tree().create_timer(TURN_DELAY).timeout


func _finish(won: bool, escaped: bool) -> void:
	finished.emit({"won": won, "escaped": escaped})
	queue_free()
