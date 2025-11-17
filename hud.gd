extends CanvasLayer

@export var speed_button_group: ButtonGroup

func _on_speed_changed(pressed_button):
	match pressed_button.name:
		"Speed1":
			Engine.time_scale = 0.2
		"Speed2":
			Engine.time_scale = 0.5
		"Speed3":
			Engine.time_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hi")
	speed_button_group.connect("pressed", _on_speed_changed)
