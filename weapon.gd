extends Node2D

@export var bullet_scene: PackedScene

@export var bps: float = 20
@export var spread_degrees: float = 20
@export var projectile_impulse: float = 400.0

@export var mag_size: int = 10
@export var reload_time: float = 1.2

var is_firing = false
var _direction: Vector2
var fire_timer := 0.0

var _ammo := mag_size
var _reloading := false
var _reload_timer := 0.0

func _start_reload():
	if _reloading:
		return
	_reloading = true
	_reload_timer = 0.0

func _spawn_bullet():
	var spread = deg_to_rad(randf_range(-spread_degrees, spread_degrees));
	var final_direction = _direction.normalized().rotated(spread);
	print("final direction: ", " ", final_direction)
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position
	bullet.radius = 2
	bullet.apply_impulse(final_direction * projectile_impulse)
	get_tree().current_scene.add_child(bullet)
	
func start_shooting(direction: Vector2):
	_direction = direction
	is_firing = true
	
func update_direction(direction: Vector2):
	_direction = direction
	
func end_shooting():
	is_firing = false
			

func _process(delta):
	if _reloading:
		_reload_timer += delta
		if _reload_timer >= reload_time:
			_ammo = mag_size
			_reloading = false 
		return
	
	if not is_firing:
		fire_timer = 0.0
		return
		
	fire_timer += delta
		
	var one_bullet_time = 1.0 / bps
	while fire_timer >= one_bullet_time:
		_spawn_bullet()
		fire_timer -= one_bullet_time
	
	
