extends Node2D

enum Difficulty { EASY, MEDIUM, DIFFICULT }


@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;
@export var difficulty: Difficulty = Difficulty.EASY

func _pause():
	get_tree().paused = true
	$PauseMenu.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event):
	# zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= Vector2(1 + zoom_speed, 1 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= Vector2(1 - zoom_speed, 1 - zoom_speed)
		
			
	if event is InputEventKey:
		if event.pressed and event.keycode == Key.KEY_ESCAPE:
			_pause()
			

func _process(delta: float):
	pass

func _physics_process(delta: float):
	#fps_label.text = "Fps: %d" % Engine.get_frames_per_second()
	
	var bodies = get_tree().get_nodes_in_group("bodies")
	#num_objects_label.text = "Num objects: %d" % bodies.size()

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


func _on_gun_reload_finished() -> void:
	print("Reload finished!")


func _on_gun_reload_started() -> void:
	print("Reload started!")


func _on_gun_shooting_started() -> void:
	print("Shooting started")


func _on_gun_shooting_stopped() -> void:
	print("Shooting stopped")


func _on_gun_magazine_changed(current_mag: int) -> void:
	print("Magazine changed: ", current_mag)


func _on_gun_bullets_changed(bullets_available: int) -> void:
	print("Bullets availabel canged: ", bullets_available)
