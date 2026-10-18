extends Node

## Rolls for a monster the first time the player enters each corridor,
## and runs the battle on top of the dungeon when one shows up.

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const MonsterSpawner = preload("res://scenes/dungeon/monster_spawner.gd")
const BattleScene = preload("res://scenes/battle/battle.tscn")

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


func _ready() -> void:
	dungeon.moved.connect(_on_moved)


func _on_moved(location: Vector2i, _facing) -> void:
	if in_battle or rolled.has(location):
		return
	rolled[location] = true

	var monster := spawner.roll(dungeon.get_current_corridor())
	if monster != null:
		start_battle(monster)


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


func _on_battle_finished(_result: Dictionary) -> void:
	in_battle = false
	current_battle = null
	movement_controller.process_mode = Node.PROCESS_MODE_INHERIT
	movement_controller.visible = true
	battle_ended.emit()

	if Game.player.hp <= 0:
		# game over for now: start the dungeon again
		Game.new_game()
		get_tree().reload_current_scene.call_deferred()
