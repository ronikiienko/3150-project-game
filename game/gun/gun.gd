class_name Gun extends Node2D

@export var gun_conf: GunConf

var _mechanics: GunMechanics
var _aiming: GunAiming

var _sprite: Sprite2D

func _fire_bullets_handler(count: int):
	for i in range(count):		
		var bullet = Bullet.new()
		
		bullet.texture = gun_conf.bullet.texture
		bullet.radius = gun_conf.bullet.radius
		bullet.mass = gun_conf.bullet.mass
		bullet.position = _aiming.get_direction() * gun_conf.size / 2.0
		bullet.time_to_live = gun_conf.bullet.time_to_live
		
		var rotation = _aiming.get_direction_rad()
		
		var spread_radians = deg_to_rad(gun_conf.spread_degrees)
		var deviation = randf_range(-spread_radians / 2.0, spread_radians / 2.0)
		var final_rotation = rotation + deviation
		
		var velocity = Vector2.from_angle(final_rotation).normalized() * gun_conf.velocity
		
		bullet.linear_velocity = velocity
		bullet.name = "bullet"
		
		get_parent().add_child(bullet)
	pass
		
func _magazine_changed_handler(current_mag: int):
	emit_signal("magazine_changed", current_mag)
	
func _reload_finished_handler():
	emit_signal("reload_finished")

func _ready() -> void:
	# Resources are references, editing bullets_available would change resource in every places it's used
	gun_conf = gun_conf.duplicate(true)
	
	_mechanics = GunMechanics.new()
	_mechanics.bps = gun_conf.bps
	_mechanics.mag_size = gun_conf.mag_size
	_mechanics.full_reload_time = gun_conf.full_reload_time
	
	_aiming = GunAiming.new()
	_aiming.rotation_speed = deg_to_rad(gun_conf.rotation_speed_degrees)
	
	_mechanics.connect("fire_bullets", _fire_bullets_handler)
	_mechanics.connect("magazine_changed", _magazine_changed_handler)
	_mechanics.connect("reload_finished", _reload_finished_handler)
	
	_sprite = Sprite2D.new()
	_sprite.z_index = 10
	_sprite.texture = gun_conf.texture
	add_child(_sprite)
	
	if gun_conf.texture:
		var tex_size = gun_conf.texture.get_size()
		_sprite.scale = Vector2(gun_conf.size / tex_size.x, gun_conf.size / tex_size.y)
	
func start_shooting():
	emit_signal("shooting_started")
	_mechanics.start_shooting()

func stop_shooting():
	emit_signal("shooting_stopped")
	_mechanics.stop_shooting()
	
func reload():
	var used = _mechanics.load_bullets(min(gun_conf.bullets_available, gun_conf.mag_size))
	gun_conf.bullets_available -= used
	emit_signal("reload_started")
	emit_signal("bullets_changed", gun_conf.bullets_available)

func _process(delta: float) -> void:
	_mechanics.update(delta)
	_aiming.update(delta)
		
	var mouse_world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	_aiming.set_target(mouse_world_pos)
	
	_sprite.rotation = _aiming.get_direction_rad()
	
func activate():
	set_process(true)
	set_physics_process(true)
	_sprite.visible = true
	
func deactivate():
	set_process(false)
	set_physics_process(false)
	_sprite.visible = false
	
	
signal magazine_changed(current_mag: int)
signal bullets_changed(bullets_available: int)
signal shooting_started()
signal shooting_stopped()
signal reload_started()
signal reload_finished()

func in_mag_count() -> int:
	return _mechanics.left_in_magazine()

func inventory_count() -> int:
	return gun_conf.bullets_available
	
func name() -> String:
	return gun_conf.name
