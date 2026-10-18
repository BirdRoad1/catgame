extends Control

## WIP pass-out cutscene: fade to black, a line of text, then wake up at home.

const HOME_SCENE := "res://scenes/home/catroom/catroom.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu/main_menu.tscn"

@export var fade_time := 1.5
@export var hold_time := 2.0

@onready var fade: ColorRect = %Fade
@onready var message: Label = %Message

## Set before adding to the tree. The owner caught the cat for the last time
var game_over := false
## Set before adding to the tree. The cat lost a fight (instead of running out of turns)
var defeated := false


func _ready() -> void:
	fade.color.a = 0.0
	message.modulate.a = 0.0
	if game_over:
		message.text = "Your owner finds you one last time... and locks the cat flap for good.\nGAME OVER"
	else:
		var how := "Beaten and bruised, you collapse" if defeated else "Exhausted, you collapse"
		message.text = "%s... and your owner carries you home. (Caught %d/%d, -%d agility)" % [
			how, Game.player.times_caught, Player.MAX_CATCHES, Player.CATCH_AGILITY_PENALTY]
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, fade_time)
	tween.tween_property(message, "modulate:a", 1.0, fade_time / 2)
	tween.tween_interval(hold_time)
	tween.tween_callback(_go_home)


## Blocks all input (including the inventory key) while the cutscene plays
func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func _go_home() -> void:
	if game_over:
		Game.new_game()
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
		return
	get_tree().change_scene_to_file(HOME_SCENE)
