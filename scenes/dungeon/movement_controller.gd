extends VBoxContainer

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction

@onready var dungeon: Dungeon = owner.dungeon

@export var forward_btn: Button
@export var turnaround_btn: Button
@export var left_btn: Button
@export var right_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	forward_btn.pressed.connect(forward)
	turnaround_btn.pressed.connect(turnaround)
	left_btn.pressed.connect(left)
	right_btn.pressed.connect(right)
	
func forward():
	dungeon.move_forward()
	print("FORWARD")
func left():
	dungeon.turn_left()
	pass
func right():
	dungeon.turn_right()
	pass
func turnaround():
	dungeon.turn_right()
	dungeon.turn_right()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_forward"):
		forward()
	if event.is_action_pressed("turnaround"):
		turnaround()
	if event.is_action_pressed("turn_left"):
		left()
	if event.is_action_pressed("turn_right"):
		right()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
