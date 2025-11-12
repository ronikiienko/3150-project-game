extends Node2D

@export var circle_scene: PackedScene
@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in 100:
		var circle = circle_scene.instantiate();
		circle.apply_force(Vector2(randf_range(-1000.0, 1000.0), randf_range(-1000, 1000.0)));
		circle.position = Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0));
		circle.radius = randf_range(1.0, 5.0);
		add_child(circle);

func _input(event):
	# zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= Vector2(1 + zoom_speed, 1 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= Vector2(1 - zoom_speed, 1 - zoom_speed)
		
	print(event)
