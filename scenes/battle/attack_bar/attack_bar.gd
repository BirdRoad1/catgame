extends Control

## Timing bar shown when the player attacks (Undertale/Sans style): a cursor
## sweeps across the bar and the player clicks when it's over the center.
## Emits finished once with how close they got.

## accuracy: 1.0 = dead center, 0.0 = missed completely
signal finished(accuracy: float)

## Seconds for one sweep across the bar. Battles set this with sweep_time_for()
@export var sweep_time := BASE_SWEEP_TIME

## Sweep time against monsters at or below your level
const BASE_SWEEP_TIME := 1.0
## Fastest the bar can get, however overleveled the monster is
const MIN_SWEEP_TIME := 0.3
## Each level the monster is above you multiplies the sweep time by this.
## 0.85 means about 8 levels above you to hit the minimum
const SPEEDUP_PER_LEVEL := 0.85

## The green bar
@export var bar: ColorRect
## The white line that sweeps across the bar. Move it with cursor.position.x
@export var cursor: ColorRect

var done := false
var going_right = true
var start_time

func _ready() -> void:
	start_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if done: return
	var elapsedSec = (Time.get_ticks_msec() - start_time) / 1000.0
	var timeRemaining = sweep_time - elapsedSec
	var widthRemaining = bar.size.x - cursor.position.x if going_right else cursor.position.x
	if (widthRemaining <= 0 || timeRemaining <= 0):
		going_right = !going_right
		start_time = Time.get_ticks_msec()
		return
	
	var progress = elapsedSec / sweep_time
	cursor.position.x = clampf(progress * bar.size.x if going_right else bar.size.x - (progress * bar.size.x), 0, bar.size.x)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var center = bar.size.x / 2
		var delta = abs(center - (cursor.position.x - cursor.size.x / 2.0))
		var accuracy = 1.0 - clampf(delta / center, 0, 1)
		_finish(accuracy)


## Sweep time for a fight, based on how many levels the monster is above the player
static func sweep_time_for(monster_level: int, player_level: int) -> float:
	var gap := maxi(monster_level - player_level, 0)
	return maxf(BASE_SWEEP_TIME * pow(SPEEDUP_PER_LEVEL, gap), MIN_SWEEP_TIME)


func _finish(accuracy: float) -> void:
	if done:
		return
	done = true
	finished.emit(clampf(accuracy, 0.0, 1.0))
	queue_free()
