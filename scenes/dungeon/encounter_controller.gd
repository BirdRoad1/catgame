extends Node

## Rolls for a chest or a monster the first time the player enters each
## corridor, and runs the battle on top of the dungeon when one shows up.

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const MonsterSpawner = preload("res://scenes/dungeon/monster_spawner.gd")
const BattleScene = preload("res://scenes/battle/battle.tscn")
## Plays the first time the boss is beaten
const COURTSHIP_SCENE := "res://scenes/courtship/courtship.tscn"
const PassOutScene = preload("res://scenes/pass_out/pass_out.tscn")

signal battle_ended
## The player attacked, tried to flee, etc. Each one costs a dungeon turn
signal battle_turn_taken

@onready var dungeon: Dungeon = owner.dungeon

## Hidden and disabled while a battle is running so the player can't walk away mid-fight
@export var movement_controller: Node

var spawner := MonsterSpawner.new()
## Corridors that have already been rolled for, so each one only gets one chance
var rolled: Dictionary[Vector2i, bool] = {Vector2i.ZERO: true}
var in_battle := false
var current_battle: Node
## The chest prompt on screen, if any
var chest_prompt: Control


func _ready() -> void:
	dungeon.moved.connect(_on_moved)


func _on_moved(location: Vector2i, _facing) -> void:
	if in_battle or rolled.has(location):
		return
	rolled[location] = true

	var corridor := dungeon.get_current_corridor()
	var chest := Chest.roll(corridor)
	if chest != null:
		show_chest(chest)
		return

	var monster := spawner.roll(corridor, Game.player.level)
	if monster != null:
		start_battle(monster)


## A chest, battle or chest prompt is on screen, so the player can't walk or open the bag
func is_busy() -> bool:
	return in_battle or chest_prompt != null


func show_chest(chest: Chest) -> void:
	_set_movement_enabled(false)
	chest_prompt = _build_chest_prompt(chest)
	owner.add_child(chest_prompt)


## Built in code for now: chest art, a message, and Open / Leave buttons
func _build_chest_prompt(chest: Chest) -> Control:
	var prompt := CenterContainer.new()
	prompt.set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	prompt.add_child(box)

	var art := TextureRect.new()
	art.texture = Chest.CLOSED_TEXTURE
	art.custom_minimum_size = Vector2(256, 256)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(art)

	var label := Label.new()
	label.text = "You found a chest!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	var open_btn := Button.new()
	open_btn.text = "Open"
	buttons.add_child(open_btn)
	var leave_btn := Button.new()
	leave_btn.text = "Leave"
	buttons.add_child(leave_btn)

	# only offered if the player has a Chest Search in their bag
	if Game.player.inventory.find_in_bag(ChestSearch) != -1:
		var search_btn := Button.new()
		search_btn.text = "Use Chest Search"
		buttons.add_child(search_btn)
		search_btn.pressed.connect(_search_chest.bind(chest, art, label, search_btn))

	open_btn.pressed.connect(_open_chest.bind(chest, art, label, buttons))
	leave_btn.pressed.connect(_close_chest)
	return prompt


## Uses up a Chest Search to reveal whether the chest is a mimic
func _search_chest(chest: Chest, art: TextureRect, label: Label, search_btn: Button) -> void:
	var index := Game.player.inventory.find_in_bag(ChestSearch)
	if index == -1:
		return
	Game.player.inventory.remove_at(index)
	search_btn.queue_free()
	if chest.is_mimic:
		art.texture = Chest.MIMIC_CLOSED_TEXTURE
		label.text = "Your Chest Search shudders... it's a mimic!"
	else:
		label.text = "Your Chest Search says it's safe. Just a chest."


func _open_chest(chest: Chest, art: TextureRect, label: Label, buttons: Control) -> void:
	buttons.hide()
	if chest.is_mimic:
		art.texture = Mimic.new().texture
		label.text = "It was a mimic!"
		await get_tree().create_timer(1.2).timeout
		_close_chest()
		var mimic := Mimic.new()
		mimic.scale_to_player_level(Game.player.level)
		start_battle(mimic)
		return

	art.texture = Chest.OPEN_TEXTURE
	var item := LootTable.roll_item()
	label.text = "You found a %s %s!" % [item.get_rarity_name(), item.display_name]
	if not Game.player.inventory.add(item):
		label.text += "\nBut your bag is full, so you leave it behind."
	await get_tree().create_timer(2.0).timeout
	_close_chest()


func _close_chest() -> void:
	if chest_prompt == null:
		return
	chest_prompt.queue_free()
	chest_prompt = null
	_set_movement_enabled(true)


func _set_movement_enabled(enabled: bool) -> void:
	movement_controller.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	movement_controller.visible = enabled


func start_battle(monster: Monster) -> void:
	in_battle = true
	movement_controller.process_mode = Node.PROCESS_MODE_DISABLED
	movement_controller.visible = false

	var battle = BattleScene.instantiate()
	battle.monster = monster
	battle.player = Game.player
	battle.finished.connect(_on_battle_finished)
	battle.turn_taken.connect(battle_turn_taken.emit)
	current_battle = battle
	owner.add_child(battle)


func _on_battle_finished(result: Dictionary) -> void:
	var monster: Monster = current_battle.monster
	in_battle = false
	current_battle = null
	movement_controller.process_mode = Node.PROCESS_MODE_INHERIT
	movement_controller.visible = true
	battle_ended.emit()

	if Game.player.hp <= 0:
		_on_defeated()
		return

	if result.won and monster is BigTom and not Game.player.beaten_boss:
		Game.player.beaten_boss = true
		get_tree().change_scene_to_file.call_deferred(COURTSHIP_SCENE)


## Losing a fight counts as getting caught: the owner finds the cat knocked
## out and carries it home (a strike and lost agility, nothing else is lost)
func _on_defeated() -> void:
	_set_movement_enabled(false)
	# enough to get home; sleeping heals the rest
	Game.player.hp = 1
	var pass_out_screen = PassOutScene.instantiate()
	pass_out_screen.defeated = true
	pass_out_screen.game_over = Game.player.get_caught()
	owner.add_child(pass_out_screen)
