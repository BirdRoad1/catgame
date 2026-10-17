extends Control

## Scene to load once the backstory dialogue ends
@export_file("*.tscn") var next_scene: String = ""


func _ready() -> void:
	$DialogueBox.dialogue_finished.connect(_on_dialogue_finished)


func _on_dialogue_finished() -> void:
	if next_scene.is_empty():
		push_warning("Backstory finished but next_scene isn't set")
		return
	get_tree().change_scene_to_file(next_scene)
