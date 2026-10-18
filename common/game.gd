extends Node

## Autoload (Game). Holds state that has to outlive scene changes.

var player: Player


func _ready() -> void:
	new_game()


func new_game() -> void:
	player = Player.new()
	for item in [HealthPotion.new(), HealthPotion.new(), BasicClaws.new(), BellCollar.new(), LuckyPaw.new()]:
		player.inventory.add(item)
