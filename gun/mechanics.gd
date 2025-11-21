## Manages basic logic: reload, fire rate, magazine size.
## Does not manage bullet creation/positions/directions
class_name GunMechanics extends Object

## Bullets per second
@export var bps: float = 20

## Maximum magazine size, after magazine runs out of bullets reload is required
@export var mag_size: int = 10
## Time it takes to FULLY reload magazine in seconds
## If reloading includes half magazine of bullets it will take half of this time for example
@export var full_reload_time: float = 1.2

var _is_firing = false
var _fire_timer := 0.0

var _ammo: int = 0
var _reloading := false
var _reload_timer := 0.0
var _left_to_load = 0


	
func start_shooting():
	_is_firing = true
	
	
func stop_shooting():
	_is_firing = false

func left_in_magazine() -> int:
	return _ammo

# Returns number of bullets actually loaded (e.g if provided amount is greater than mag_size 
# or there already were bullets in magazine)
func load_bullets(amount: int) -> int:
	var empty_slots = mag_size - _ammo
	
	if amount <= 0:
		return 0
		
	var to_reload = min(amount, empty_slots)
	_reloading = true
	_reload_timer = 0.0
	_left_to_load = to_reload
	
	return to_reload
		

func update(delta: float):		
	if _reloading:
		_reload_timer += delta
		var one_bullet_reload_time = full_reload_time / mag_size
		while _reload_timer >= one_bullet_reload_time:
			if _left_to_load <= 0:
				_reloading = false
				emit_signal("reload_finished")
				break
				
			_reload_timer -= one_bullet_reload_time
			_left_to_load -= 1
			_ammo += 1
			emit_signal("magazine_changed", _ammo)
		return
	
	
	var one_bullet_time = 1.0 / bps	

	if not _is_firing:
		# ensure that after not shooting first shot is immediate
		_fire_timer = min(one_bullet_time, _fire_timer + delta)
		return
		
	_fire_timer += delta
		
	var count = 0
	while _fire_timer >= one_bullet_time and _ammo > 0:
		count += 1
		_fire_timer -= one_bullet_time
		_ammo -= 1
		
	emit_signal("magazine_changed", _ammo)
	
	emit_signal("fire_bullets", count)
		
signal fire_bullets(count: int)
signal reload_finished()
signal magazine_changed(current_mag: int)
