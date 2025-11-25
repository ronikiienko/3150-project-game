extends Node2D

enum Difficulty { EASY, MEDIUM, DIFFICULT }


@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;
@export var difficulty: Difficulty = Difficulty.EASY
@export var level_conf: LevelConf

func _pause():
	get_tree().paused = true
	$PauseMenu.visible = true

var GunScene = preload("res://gun/gun.tscn")

var gun_nodes: Array[Gun] = []
var active_gun: Gun

@onready var HUD = $HUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for gun_conf in level_conf.available_guns:
		print("Gun conf")
		var typed_gun_conf = gun_conf as GunConf
		var gun_node = GunScene.instantiate() as Gun
		gun_node.texture = typed_gun_conf.texture
		gun_node.size = typed_gun_conf.size
		gun_node.spread_radians = deg_to_rad(typed_gun_conf.spread_degrees) 
		gun_node.impulse = typed_gun_conf.impulse
		gun_node.bullets_available = typed_gun_conf.bullets_available
		gun_node.bullet_mass = typed_gun_conf.bullet.mass
		gun_node.bullet_gravity = typed_gun_conf.bullet.gravity
		gun_node.bullet_radius = typed_gun_conf.bullet.radius
		gun_node.bullet_texture = typed_gun_conf.bullet.texture
		
		gun_node.bps = typed_gun_conf.bps
		
		gun_node.mag_size = typed_gun_conf.mag_size
		gun_node.full_reload_time = typed_gun_conf.full_reload_time
		gun_node.rotation_speed = deg_to_rad(typed_gun_conf.rotation_speed_degrees)
		
		gun_node.gun_name = gun_conf.name

		gun_nodes.push_back(gun_node)
		
		add_child(gun_node)
		
		gun_node.deactivate()
		
	switch_gun(0)
	

func switch_gun(index: int):
	if active_gun:
		active_gun.deactivate()
		active_gun.disconnect("magazine_changed", _on_magazine_changed)
		active_gun.disconnect("bullets_changed", _on_total_left_changed)
		
	active_gun = gun_nodes[index]
	active_gun.activate()
	HUD.update_available_guns(gun_nodes)
	print("Switched. changed")
	HUD.update_bullet_state(active_gun.in_mag_count(), active_gun.bullets_available)
	
	active_gun.connect("magazine_changed", _on_magazine_changed)
	active_gun.connect("bullets_changed", _on_total_left_changed)
		
func _on_magazine_changed(new_count: int):
	HUD.update_bullet_state(new_count, active_gun.bullets_available)
	
func _on_total_left_changed(new_count: int):
	HUD.update_bullet_state(active_gun.in_mag_count(), new_count)

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
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		active_gun.start_shooting()
		
	if event.is_action_released("shoot"):
		active_gun.stop_shooting()
		
	if event.is_action_pressed("reload"):
		active_gun.reload()

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


func _on_hud_gun_switched(index: int) -> void:
	switch_gun(index)
