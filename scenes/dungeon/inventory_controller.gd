extends Node

## Opens the inventory on top of the dungeon with the toggle_inventory key (I).

const InventoryScene = preload("res://scenes/inventory/inventory.tscn")

## Hidden and disabled while the inventory is open
@export var movement_controller: Node
## So the inventory can't be opened mid-fight
@export var encounter_controller: Node

var is_open := false


func _unhandled_input(event: InputEvent) -> void:
	if is_open or encounter_controller.in_battle:
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
