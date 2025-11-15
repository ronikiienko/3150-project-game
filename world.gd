extends Node2D

@export var circle_scene: PackedScene
@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;

@onready var fps_label = $CanvasLayer/FpsLabel
@onready var num_objects_label = $CanvasLayer/NumObjectsLabel

const CIRCLE_TEXTURE = preload("res://img.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#for i in 200:
		#var circle = circle_scene.instantiate() as Circle;
		#circle.texture = CIRCLE_TEXTURE;
		#circle.apply_force(Vector2(randf_range(-1000.0, 1000.0), randf_range(-1000, 1000.0)));
		#circle.position = Vector2(randf_range(-1000.0, 1000.0), randf_range(-1000.0, 1000.0));
		#circle.radius = randf_range(1.0, 5.0);
		#add_child(circle);
		#circle.add_to_group("bodies")

func _input(event):
	# zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= Vector2(1 + zoom_speed, 1 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= Vector2(1 - zoom_speed, 1 - zoom_speed)
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
				weapon.start_shooting(mouse_world_pos.normalized())
			else:
				weapon.end_shooting()

@onready var weapon = $Weapon

func _process(delta: float):
	var mouse_world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	weapon.update_direction(mouse_world_pos.normalized())

func _physics_process(delta: float):
	fps_label.text = "Fps: %d" % Engine.get_frames_per_second()
	
	var bodies = get_tree().get_nodes_in_group("bodies")
	num_objects_label.text = "Num objects: %d" % bodies.size()

	var G = 5000.0  # gravity strength constant, tune this
	for i in bodies.size():
		var b1 = bodies[i]
		var p1 = b1.position

		for j in range(i + 1, bodies.size()):
			var b2 = bodies[j]
			var p2 = b2.position

			var dir = p2 - p1
			var dist_sq = dir.length_squared()

			if dist_sq < 1.0:
				continue  # prevent blowups

			var force_mag = G / dist_sq
			var force = dir.normalized() * force_mag

		# apply equal and opposite forces
			b1.apply_force(force)
			b2.apply_force(-force)
			
	
