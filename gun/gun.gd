class_name Gun extends Node2D

@export var gun_name: String
				
@export var texture: Texture2D
@export var size: float

@export var spread_radians: float
@export var impulse: float
@export var bullets_available: int

@export var bullet_mass: float
@export var bullet_gravity: float
@export var bullet_radius: float
@export var bullet_texture: Texture2D

@export var bps: float = 20
@export var mag_size: int = 10
@export var full_reload_time: float = 1.2

@export var rotation_speed: float

var _mechanics: GunMechanics
var _aiming: GunAiming

var _bullet_scene := preload("res://gun/bullet.tscn")

var _sprite: Sprite2D

func _fire_bullets_handler(count: int):
	for i in range(count):		
		var bullet = _bullet_scene.instantiate()
		
		bullet.texture = bullet_texture
		bullet.radius = bullet_radius
		bullet.mass = bullet_mass
		bullet.position = _aiming.get_direction() * size / 2.0
		
		var rotation = _aiming.get_direction_rad()
		
		var deviation = randf_range(-spread_radians / 2.0, spread_radians / 2.0)
		var final_rotation = rotation + deviation
		
		var current_impulse = Vector2(cos(final_rotation), sin(final_rotation)).normalized() * impulse
		
		bullet.apply_impulse(current_impulse)
		
		get_parent().add_child(bullet)
		
func _magazine_changed_handler(current_mag: int):
	emit_signal("magazine_changed", current_mag)
	
func _reload_finished_handler():
	emit_signal("reload_finished")

func _ready() -> void:
	_mechanics = GunMechanics.new()
	_mechanics.bps = bps
	_mechanics.mag_size = mag_size
	_mechanics.full_reload_time = full_reload_time
	
	_aiming = GunAiming.new()
	_aiming.rotation_speed = rotation_speed
	
	_mechanics.connect("fire_bullets", _fire_bullets_handler)
	_mechanics.connect("magazine_changed", _magazine_changed_handler)
	_mechanics.connect("reload_finished", _reload_finished_handler)
	
	_sprite = Sprite2D.new()
	_sprite.z_index = 10
	_sprite.texture = texture
	add_child(_sprite)
	
	if texture:
		var tex_size = texture.get_size()
		_sprite.scale = Vector2(size / tex_size.x, size / tex_size.y)
	
func start_shooting():
	emit_signal("shooting_started")
	_mechanics.start_shooting()

func stop_shooting():
	emit_signal("shooting_stopped")
	_mechanics.stop_shooting()
	
func reload():
	var used = _mechanics.load_bullets(min(bullets_available, mag_size))
	bullets_available -= used
	emit_signal("reload_started")
	emit_signal("bullets_changed", bullets_available)

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
	
func load_from_conf(conf: GunConf):
	gun_name = conf.name
	texture = conf.texture
	size = conf.size
	spread_radians = deg_to_rad(conf.spread_degrees)
	impulse = conf.impulse
	bullets_available = conf.bullets_available

	bullet_mass = conf.bullet.mass
	bullet_gravity = conf.bullet.gravity
	bullet_radius = conf.bullet.radius
	bullet_texture = conf.bullet.texture

	bps = conf.bps
	mag_size = conf.mag_size
	full_reload_time = conf.full_reload_time
	rotation_speed = deg_to_rad(conf.rotation_speed_degrees)
