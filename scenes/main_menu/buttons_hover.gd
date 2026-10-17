extends Label

var old_font_color: Color = label_settings.font_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_mouse_entered() -> void:
	label_settings.font_color = Color("96b8ebff")
	print("Mouse is hovering over the UI element!")

func _on_mouse_exited() -> void:
	label_settings.font_color = old_font_color
	print("Mouse left the UI element.")
