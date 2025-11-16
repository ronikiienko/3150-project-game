## Manages shooting logic: reload, fire rate, magazine size.
## Does not manage bullet creation - only emits signal
class_name Weapon extends Node2D


## Bullets per second
@export var bps: float = 20
## Angle that full spread cone covers
@export var spread_degrees: float = 20
## This impulse will be applied to created projectile in specified direction
@export var projectile_impulse: float = 400.0

## Maximum magazine size, after magazine runs out of bullets reload is required
@export var mag_size: int = 10
## Time it takes to FULLY reload magazine in seconds
## If reloading includes half magazine of bullets it will take half of this time for example
@export var full_reload_time: float = 1.2

var _is_firing = false
var _direction: Vector2
var _fire_timer := 0.0

var _ammo: int = 0
var _reloading := false
var _reload_timer := 0.0
var _left_to_load = 0


	
func start_shooting(direction: Vector2):
	_direction = direction
	_is_firing = true
	
func update_direction(direction: Vector2):
	_direction = direction
	
func end_shooting():
	_is_firing = false

func left_in_magazine() -> int:
	return _ammo

# Returns number of bullets actually loaded (e.g if provided amount is greater than mag_size 
# or there already were bullets in magazine)
func topup_magazine(amount: int) -> int:
	var empty_slots = mag_size - _ammo
	
	if amount <= 0:
		return 0
		
	var to_reload = min(amount, empty_slots)
	_reloading = true
	_reload_timer = 0.0
	_left_to_load = to_reload
	
	return to_reload
		
			
func _spawn_bullet() -> FireBulletData:
	var spread = deg_to_rad(randf_range(-spread_degrees / 2, spread_degrees / 2));
	var final_direction = _direction.normalized().rotated(spread);
	return FireBulletData.new(final_direction * projectile_impulse)

func _process(delta):		
	if _reloading:
		_reload_timer += delta
		var one_bullet_reload_time = full_reload_time / mag_size
		while _reload_timer >= one_bullet_reload_time:
			if _left_to_load <= 0:
				emit_signal("topup_finished")
				_reloading = false
				break
				
			_reload_timer -= one_bullet_reload_time
			_left_to_load -= 1
			_ammo += 1
			emit_signal("bullet_loaded", _ammo, _left_to_load)
		return
	
	if not _is_firing:
		_fire_timer = 0.0
		return
		
	_fire_timer += delta
		
	var one_bullet_time = 1.0 / bps
	
	var bullets: Array[FireBulletData] = []
	while _fire_timer >= one_bullet_time and _ammo > 0:
		var bullet = _spawn_bullet()
		bullets.append(bullet)
		_fire_timer -= one_bullet_time
		_ammo -= 1
	
	emit_signal("fire_bullets", bullets)
		
signal fire_bullets(bullets: Array[FireBulletData])
signal topup_finished()
signal bullet_loaded(current_ammo: int, left_to_load: int)
