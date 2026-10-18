extends PanelContainer
## Shows lines from a Dialogue Manager file in this box.

signal dialogue_finished

## The dialogue file to play
@export var dialogue_resource: DialogueResource = preload("res://scenes/backstory/backstory.dialogue")

## The title in the dialogue file to start from
@export var start_from: String = "start"

## The action that advances the dialogue (in addition to left click)
@export var next_action: StringName = &"ui_accept"

@onready var speaker_label: Label = %SpeakerName
@onready var dialogue_label: DialogueLabel = %DialogueText
@onready var continue_hint: Label = %ContinueHint
@onready var scene_art: TextureRect = %SceneArt
@onready var box_blur: TextureRect = %BoxBlur

## Where [code][#art=name][/code] tags look for name.png
@export_dir var art_folder: String = "res://scenes/backstory/art"

var dialogue_line: DialogueLine
var is_waiting_for_input: bool = false

## Holding Ctrl fast-forwards: typing finishes instantly and lines advance
## every SKIP_INTERVAL seconds (timed lines too)
const SKIP_INTERVAL := 0.08
var skip_cooldown := 0.0


func _ready() -> void:
	start()


func start() -> void:
	show()
	next(start_from)


## Fetch and show the line with the given id
func next(next_id: String) -> void:
	is_waiting_for_input = false
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id)
	if dialogue_line == null:
		hide()
		box_blur.hide()
		dialogue_finished.emit()
		return
	apply_dialogue_line()


func apply_dialogue_line() -> void:
	continue_hint.hide()

	# [#art=name] swaps the scene image; it stays until another line changes it
	if dialogue_line.has_tag("art"):
		scene_art.texture = load("%s/%s.png" % [art_folder, dialogue_line.get_tag_value("art")])

	# Lines with no text (just art) hide the box entirely
	visible = not dialogue_line.text.is_empty()
	box_blur.visible = visible

	speaker_label.visible = not dialogue_line.character.is_empty()
	speaker_label.text = dialogue_line.character

	dialogue_label.dialogue_line = dialogue_line

	# [next=3] in a line: move on by itself after that many seconds, ignoring
	# input (except holding Ctrl, which cuts the wait short)
	if is_auto_advance():
		var line := dialogue_line
		var timer := get_tree().create_timer(dialogue_line.time.to_float())
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
		while timer.time_left > 0 and not is_skipping():
			await get_tree().process_frame
		if is_skipping():
			await get_tree().create_timer(SKIP_INTERVAL).timeout
		# skipping may have already moved past this line
		if dialogue_line == line:
			next(dialogue_line.next_id)
		return

	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	is_waiting_for_input = true
	continue_hint.show()


func is_skipping() -> bool:
	return Input.is_key_pressed(KEY_CTRL)


func _process(delta: float) -> void:
	skip_cooldown -= delta
	if dialogue_line == null or not is_skipping() or is_auto_advance() or skip_cooldown > 0:
		return
	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
	elif is_waiting_for_input:
		skip_cooldown = SKIP_INTERVAL
		next(dialogue_line.next_id)


func is_auto_advance() -> bool:
	return dialogue_line != null and dialogue_line.time != ""


func _input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	if not (clicked or event.is_action_pressed(next_action)):
		return
	if dialogue_line == null:
		return

	get_viewport().set_input_as_handled()

	if is_auto_advance():
		return

	# First press finishes the typing, the next one advances
	if dialogue_label.is_typing:
		dialogue_label.skip_typing()
	elif is_waiting_for_input:
		next(dialogue_line.next_id)
