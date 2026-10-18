extends Node

## Counts the player's turns in the dungeon: every step, and every action in a
## fight. Steps heal any out-of-combat regen. Running out of turns makes the
## player pass out and go home.

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const PassOutScene = preload("res://scenes/pass_out/pass_out.tscn")

@onready var dungeon: Dungeon = owner.dungeon

@export var movement_controller: Node
## Passing out waits for a fight in progress to end first
@export var encounter_controller: Node
@export var turns_label: Label

var last_location := Vector2i.ZERO
var passed_out := false


func _ready() -> void:
	dungeon.moved.connect(_on_moved)
	encounter_controller.battle_turn_taken.connect(_spend_turn)
	Game.player.leveled_up.connect(_on_leveled_up)
	_update_label()


func _exit_tree() -> void:
	# the player outlives this scene, so don't leave a dead connection behind
	if Game.player.leveled_up.is_connected(_on_leveled_up):
		Game.player.leveled_up.disconnect(_on_leveled_up)


func _on_moved(location: Vector2i, _facing) -> void:
	# turning in place also emits moved, but only steps cost a turn
	if passed_out or location == last_location:
		return
	last_location = location
	Game.player.heal(Game.player.get_regen_per_turn())
	_spend_turn()


func _spend_turn() -> void:
	if passed_out:
		return
	Game.player.turns_left -= 1
	_update_label()
	if Game.player.turns_left <= 0:
		pass_out()


## Levelling up gives extra turns (see Player.gain_xp), so refresh the counter
func _on_leveled_up(_level: int) -> void:
	_update_label()


func pass_out() -> void:
	passed_out = true
	if encounter_controller.in_battle:
		encounter_controller.current_battle.stop_after_round = true
		await encounter_controller.battle_ended
	if Game.player.hp <= 0:
		return # lost the fight; the game over takes care of it

	movement_controller.process_mode = Node.PROCESS_MODE_DISABLED
	movement_controller.visible = false
	owner.add_child(PassOutScene.instantiate())


func _update_label() -> void:
	turns_label.text = "Turns left: %d" % maxi(Game.player.turns_left, 0)
