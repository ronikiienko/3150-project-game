extends Node2D

@export var camera: Camera2D;
@export var zoom_speed: float = 0.1;
@export var level_conf: LevelConf

var _attack_system: AttackSystem

var gun_nodes: Array[Gun] = []
var active_gun: Gun

var _score: int = 0

@onready var HUD = $HUD

func _asteroid_destroyed_handler(asteroid: Asteroid, destroyed_by: Node):
	if destroyed_by is Bullet:
		_score += asteroid.max_health
		HUD.update_score(_score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD.set_available_speeds(level_conf.game_speeds, level_conf.default_speed_index)
	
	_attack_system = AttackSystem.new()
	_attack_system.attack_schedule = level_conf.attack_schedule
	_attack_system.connect("asteroid_destroyed", _asteroid_destroyed_handler)
	
	_health = level_conf.health
	
	add_child(_attack_system)
	
	for gun_conf in level_conf.available_guns:
		print("Gun conf")
		var typed_gun_conf = gun_conf as GunConf
		var gun_node = Gun.new()
		gun_node.gun_conf = typed_gun_conf

		gun_nodes.push_back(gun_node)
		
		add_child(gun_node)
		
		gun_node.deactivate()
		
	switch_gun(0)
	
	HUD.update_health(_health, level_conf.health)
	

func switch_gun(index: int):
	if active_gun:
		active_gun.deactivate()
		active_gun.disconnect("magazine_changed", _on_magazine_changed)
		active_gun.disconnect("bullets_changed", _on_total_left_changed)
		active_gun.disconnect("collision", _on_gun_collision)
		
	active_gun = gun_nodes[index]
	active_gun.activate()
	HUD.update_available_guns(gun_nodes)
	HUD.update_magazine(active_gun.in_mag_count(), active_gun.mag_size())
	HUD.update_inventory(active_gun.inventory_count())
	HUD.update_current_gun(active_gun.gun_conf.name)
	
	active_gun.connect("magazine_changed", _on_magazine_changed)
	active_gun.connect("bullets_changed", _on_total_left_changed)
	active_gun.connect("collision", _on_gun_collision)
		
func _on_magazine_changed(new_count: int):
	HUD.update_magazine(new_count, active_gun.mag_size())
	
func _on_total_left_changed(new_count: int):
	HUD.update_inventory(new_count)
	

func _process(delta: float):
	_cleanup(delta)
	if _attack_system.is_spawning_done():
		get_tree().change_scene_to_file("res://game/endgame_screens/win.tscn")
		
	var dt_unscaled := delta / Engine.time_scale

	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1

	if dir != Vector2.ZERO:
		dir = dir.normalized()

	var target_velocity = dir * level_conf.camera_speed

	# Smooth factor based on desired response time (tau)
	var tau = 0.2  # seconds to reach ~63% of target velocity
	var alpha = 1.0 - exp(-dt_unscaled / tau)

	_cam_vel = _cam_vel.lerp(target_velocity, alpha)

	# Move camera, independent of zoom
	camera.position += _cam_vel * dt_unscaled

	# Clamp to world radius
	var r = level_conf.world_radius
	var dist = camera.position.length()
	if dist > r:
		camera.position = camera.position.normalized() * r
		

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			HUD.update_note("")
		
func _handle_asteroid_note(asteroid: Asteroid):
	var text = "Asteroid\n"
	text += "Health: %d / %d\n" % [asteroid.health, asteroid.max_health]
	text += "Damage on hit: %d\n" % asteroid.damage
	text += "Time to live: %.2f s\n" % asteroid.time_to_live
	text += "Radius: %.2f\n" % asteroid.radius
	text += "Gravity strength: %.2f" % asteroid.gravity_strength
	
	HUD.update_note(text)
	
func _handle_bullet_note(bullet: Bullet):
	var text = "Bullet\n"
	text += "Health: %d\n" % bullet.health
	text += "Damage: %d\n" % bullet.damage
	text += "Time to live: %.2f s\n" % bullet.time_to_live
	text += "Radius: %.2f\n" % bullet.radius
	text += "Gravity strength: %.2f" % bullet.gravity_strength
	
	HUD.update_note(text)
	
func _handle_gun_note(gun: Gun):
	var conf = gun.gun_conf
	var bullet = conf.bullet
	
	var text = "Gun\n"
	text += "Name: %s\n" % conf.name
	text += "Description: %s\n" % conf.description
	text += "Bullets per second: %.2f\n" % conf.bps
	text += "Spread: %.1f°\n" % conf.spread_degrees
	text += "Velocity: %.1f\n" % conf.velocity
	text += "Magazine size: %d\n" % conf.mag_size
	text += "Full reload time: %.2f s\n" % conf.full_reload_time
	text += "Rotation speed: %.1f°/s\n" % conf.rotation_speed_degrees
	text += "\nGun bullets\n"
	text += "Mass: %.2f\n" % bullet.mass
	text += "Gravity: %.2f\n" % bullet.gravity
	text += "Radius: %.2f\n" % bullet.radius
	text += "Health: %d\n" % bullet.health
	text += "Damage: %d" % bullet.damage

	HUD.update_note(text)

var _cam_vel := Vector2.ZERO

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
			
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var pos = get_global_mouse_position()

		var query = PhysicsPointQueryParameters2D.new()
		query.position = pos
		
		var objects_under_click = get_world_2d().direct_space_state.intersect_point(query)
		
		for item in objects_under_click:
			var collider = item.collider

			var p = collider
			while p:
				if p is Bullet:
					_handle_bullet_note(p)
					break
				if p is Asteroid:
					_handle_asteroid_note(p)
					break
				if p is Gun:
					_handle_gun_note(p)
				p = p.get_parent()
				

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
	
func _draw():
	draw_circle(Vector2.ZERO, level_conf.world_radius, Color())


func _pause():
	get_tree().paused = true
	$PauseMenu.visible = true
	
func _unpause():
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
	if get_tree().paused:
		_unpause()
	else:
		_pause()

var _health: int

func _go_to_fail_scene():
	get_tree().change_scene_to_file("res://game/endgame_screens/fail.tscn")

func _on_gun_collision(body: Node):
	if body is Asteroid:
		_health -= body.damage
		body.call_deferred("queue_free")
		
	HUD.update_health(_health, level_conf.health)
		
	if _health <= 0:
		call_deferred("_go_to_fail_scene")
	


func _on_hud_gun_hovered(hovered_gun: int) -> void:
	var gun = gun_nodes[hovered_gun]
	_handle_gun_note(gun)


func _on_hud_gun_hovered_over() -> void:
	HUD.update_note("")
