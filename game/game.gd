extends Node2D

enum Difficulty { EASY, MEDIUM, DIFFICULT }


@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;
@export var level_conf: LevelConf



var GunScene = preload("res://game/gun/gun.tscn")

var gun_nodes: Array[Gun] = []
var active_gun: Gun

@onready var HUD = $HUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var attack_system = AttackSystem.new()
	attack_system.attack_schedule = level_conf.attack_schedule
	add_child(attack_system)
	
	for gun_conf in level_conf.available_guns:
		print("Gun conf")
		var typed_gun_conf = gun_conf as GunConf
		var gun_node = GunScene.instantiate() as Gun
		gun_node.gun_conf = typed_gun_conf

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
	HUD.update_bullet_state(active_gun.in_mag_count(), active_gun.inventory_count())
	
	active_gun.connect("magazine_changed", _on_magazine_changed)
	active_gun.connect("bullets_changed", _on_total_left_changed)
		
func _on_magazine_changed(new_count: int):
	HUD.update_bullet_state(new_count, active_gun.inventory_count())
	
func _on_total_left_changed(new_count: int):
	HUD.update_bullet_state(active_gun.in_mag_count(), new_count)
	

func _process(delta: float):
	_cleanup(delta)
	pass
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		active_gun.start_shooting()
		
	if event.is_action_released("shoot"):
		active_gun.stop_shooting()
		
	if event.is_action_pressed("reload"):
		active_gun.reload()
		
		# zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= Vector2(1 + zoom_speed, 1 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= Vector2(1 - zoom_speed, 1 - zoom_speed)

func _physics_process(delta: float):
	
	var bodies = get_tree().get_nodes_in_group("bodies") as Array[Body]

	var G = level_conf.global_gravity

	for i in range(bodies.size()):
		var b1 = bodies[i]
		var p1 = b1.position
		var g1 = b1.gravity_strength  # body-specific gravity factor

		for j in range(i + 1, bodies.size()):
			var b2 = bodies[j]
			var p2 = b2.position
			var g2 = b2.gravity_strength

			var dir = p2 - p1
			var dist_sq = dir.length_squared()
			if dist_sq < 1.0:
				continue  # avoid huge forces

			# so that two objects with negative gravity don't pull each other
			if g1 < 0 and g2 < 0:
				dir = -dir
			
			var force_mag = G * g1 * g2 / dist_sq
			var force = dir.normalized() * force_mag

			b1.apply_force(force)
			b2.apply_force(-force)


func _on_hud_gun_switched(index: int) -> void:
	switch_gun(index)


func _on_hud_sim_speed_changed(new_speed: float) -> void:
	Engine.time_scale = new_speed
	
func _cleanup(delta: float):
	for body in get_tree().get_nodes_in_group("bodies"):
		var body_typed = body as Body
		var dist_from_center = body_typed.position.length()
		if dist_from_center > level_conf.world_radius:
			body_typed.queue_free()
			
		if body is Bullet:
			body.time_to_live -= delta
			if body.time_to_live <= 0:
				body.queue_free()
				
		if body is Asteroid:
			body.time_to_live -= delta
			if body.time_to_live <= 0:
				body.queue_free()
	pass


func _pause():
	get_tree().paused = true
	$PauseMenu.visible = true
	
func _unpause():
	print("Unpause")
	get_tree().paused = false
	$PauseMenu.visible = false 

func _on_pause_menu_main_menu() -> void:
	_unpause()
	get_tree().change_scene_to_file("res://main.tscn")


func _on_pause_menu_quit() -> void:
	get_tree().quit()
	
func _on_pause_menu_restart() -> void:
	_unpause()
	get_tree().change_scene_to_file("res://choose_level.tscn")


func _on_pause_menu_toggle_pause() -> void:
	print("Toggle")
	if get_tree().paused:
		_unpause()
	else:
		_pause()
