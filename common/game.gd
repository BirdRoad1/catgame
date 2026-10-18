extends Node

## Autoload (Game). Holds state that has to outlive scene changes.

var player: Player
## F3 toggles debug info (like the dungeon coordinates). Hidden at start
var show_debug := false
signal debug_toggled(visible: bool)


func _ready() -> void:
	new_game()


func new_game() -> void:
	player = Player.new()
	for item in [MilkPotion.new(), MilkPotion.new(), BasicClaws.new(), BellCollar.new(), LuckyPaw.new()]:
		player.inventory.add(item)


## Debug: Y levels up once, the normal way (stats, stat point, evolution).
## Only in debug builds, so it's gone from exported releases
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		show_debug = not show_debug
		debug_toggled.emit(show_debug)
		return
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Y:
		player.gain_xp(player.get_xp_to_next_level() - player.xp)
		print("[debug] levelled up to %d" % player.level)
