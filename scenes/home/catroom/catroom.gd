extends Control

## How long the room takes to fade in from black
@export var fade_in_time: float = 1.0

@onready var fade: ColorRect = %Fade
@onready var message: Label = %Message

const DUNGEON_SCENE := "res://scenes/dungeon/dungeon.tscn"

## How long to stay dark while sleeping, and how long messages stay up
@export var sleep_time: float = 1.5
@export var message_time: float = 2.5

var busy := false
var message_tween: Tween


func _ready() -> void:
	fade.show()
	fade.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 0.0, fade_in_time)
	tween.tween_callback(fade.hide)


func _on_leave_pressed() -> void:
	if busy:
		return
	if Game.player.turns_left <= 0:
		show_message("You're too exhausted to go out. Get some sleep first.")
		return
	get_tree().change_scene_to_file(DUNGEON_SCENE)


func _on_bed_pressed() -> void:
	if busy:
		return
	busy = true
	fade.show()
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, fade_in_time)
	tween.tween_callback(Game.player.rest)
	tween.tween_interval(sleep_time)
	tween.tween_property(fade, "color:a", 0.0, fade_in_time)
	tween.tween_callback(fade.hide)
	await tween.finished
	busy = false
	show_message("You wake up feeling rested.")


func show_message(text: String) -> void:
	if message_tween:
		message_tween.kill()
	message.text = text
	message.modulate.a = 1.0
	message_tween = create_tween()
	message_tween.tween_interval(message_time)
	message_tween.tween_property(message, "modulate:a", 0.0, 0.5)
