class_name GunAiming extends Object

# Radians per second
@export var rotation_speed: float

var _target = Vector2(1.0, 0.0)
var _current_direction = _target

func set_target(target: Vector2):
	_target = target.normalized()
	
func update(delta: float):
	var current_angle = _current_direction.angle()
	var target_angle = _target.angle()
	
	var new_angle = lerp_angle(current_angle, target_angle, rotation_speed * delta)
	
	_current_direction = Vector2(cos(new_angle), sin(new_angle)).normalized()

func get_direction() -> Vector2:
	return _current_direction
	
func get_direction_rad() -> float:
	return _current_direction.angle()
