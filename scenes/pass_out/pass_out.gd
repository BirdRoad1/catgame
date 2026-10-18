extends Control

## WIP pass-out cutscene: fade to black, a line of text, then wake up at home.

const HOME_SCENE := "res://scenes/home/catroom/catroom.tscn"

@export var fade_time := 1.5
@export var hold_time := 2.0

@onready var fade: ColorRect = %Fade
@onready var message: Label = %Message


func _ready() -> void:
	fade.color.a = 0.0
	message.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, fade_time)
	tween.tween_property(message, "modulate:a", 1.0, fade_time / 2)
	tween.tween_interval(hold_time)
	tween.tween_callback(_go_home)


## Blocks all input (including the inventory key) while the cutscene plays
func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func _go_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)
