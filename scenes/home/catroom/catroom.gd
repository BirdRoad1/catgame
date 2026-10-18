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
var stats_label: Label


func _ready() -> void:
	_build_stats_panel()
	Game.player.leveled_up.connect(_on_leveled_up)
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
	if Game.player.is_too_hurt_to_leave():
		show_message("You're too hurt to go out. Get some sleep first.")
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
	_update_stats()
	show_message("Day %d. You wake up feeling rested." % Game.player.day)


func show_message(text: String) -> void:
	if message_tween:
		message_tween.kill()
	message.text = text
	message.modulate.a = 1.0
	message_tween = create_tween()
	message_tween.tween_interval(message_time)
	message_tween.tween_property(message, "modulate:a", 0.0, 0.5)


## Day and stats (built in code for now). Free stat points are spent in the inventory
func _build_stats_panel() -> void:
	var panel := VBoxContainer.new()
	panel.position = Vector2(16, 16)
	add_child(panel)
	move_child(panel, fade.get_index()) # keep it under the fade
	stats_label = Label.new()
	panel.add_child(stats_label)
	_update_stats()


func _update_stats() -> void:
	var p := Game.player
	stats_label.text = "Day %d   Lv %d   Caught %d/%d\nHP %d (%d/%d)   Atk %d   Agi %d (%d turns)\nFree stat points: %d (spend them in the inventory)" % [
		p.day, p.level, p.times_caught, Player.MAX_CATCHES,
		p.base_hp_stat, p.hp, p.get_max_hp(), p.base_attack_power,
		p.base_agility, p.get_max_dungeon_turns(), p.stat_points]


func _exit_tree() -> void:
	if Game.player.leveled_up.is_connected(_on_leveled_up):
		Game.player.leveled_up.disconnect(_on_leveled_up)


func _on_leveled_up(_level: int) -> void:
	_update_stats()
