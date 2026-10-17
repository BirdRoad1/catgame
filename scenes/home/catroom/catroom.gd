extends Control

## How long the room takes to fade in from black
@export var fade_in_time: float = 1.0

@onready var fade: ColorRect = %Fade


func _ready() -> void:
	fade.show()
	fade.color.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 0.0, fade_in_time)
	tween.tween_callback(fade.hide)


func _on_leave_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/backstory/dungeon.tscn")
