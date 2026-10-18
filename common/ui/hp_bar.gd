class_name HpBar
extends Control

## Simple rectangle HP bar. Green when healthy, yellow when hurt, red when low.

const HURT_RATIO := 0.5
const LOW_RATIO := 0.25

@export var ok_color := Color(0.3, 0.8, 0.3)
@export var hurt_color := Color(0.95, 0.8, 0.2)
@export var low_color := Color(0.9, 0.25, 0.2)
@export var back_color := Color(0, 0, 0, 0.6)
@export var border_color := Color(1, 1, 1, 0.9)
@export var border_width := 3.0

var hp := 1
var max_hp := 1


func set_hp(p_hp: int, p_max_hp: int) -> void:
	hp = p_hp
	max_hp = maxi(p_max_hp, 1)
	queue_redraw()


func get_color() -> Color:
	var ratio := float(hp) / max_hp
	if ratio <= LOW_RATIO:
		return low_color
	if ratio <= HURT_RATIO:
		return hurt_color
	return ok_color


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, back_color)
	var fill := rect.grow(-border_width)
	fill.size.x *= clampf(float(hp) / max_hp, 0.0, 1.0)
	draw_rect(fill, get_color())
	draw_rect(rect, border_color, false, border_width)
