extends Node
class_name AttackSystem

@export var attack_schedule: AttackScheduleConf

# Internal state
var current_time: float = 0.0
var active_attacks: Array = []

func _ready() -> void:
	print("AttackSystem ready. Schedule has %d items." % attack_schedule.attack_schedule_items.size())

func _process(delta: float) -> void:
	current_time += delta
	
	# Start attacks whose time has come
	for item in attack_schedule.attack_schedule_items:
		if not item.has_meta("started") and item.start_time <= current_time:
			start_attack(item)
			item.set_meta("started", true)

	# Process ongoing attacks
	for attack_data in active_attacks:
		attack_data.time_since_last += delta
		if attack_data.time_since_last >= attack_data.attack.interval:
			trigger_attack(attack_data.attack)
			attack_data.time_since_last = 0
			attack_data.times_done += 1

	# Remove finished attacks
	active_attacks = active_attacks.filter(func(a): return a.times_done < a.attack.count)

# Initialize a scheduled attack
func start_attack(item: AttackScheduleItem) -> void:
	active_attacks.append({
		"attack": item.attack,
		"time_since_last": 0.0,
		"times_done": 0
	})

func trigger_attack(attack: AttackConf) -> void:
	var asteroid_instance = Asteroid.new()
	
	var angle_rad = deg_to_rad(attack.angle_base_deg + randf_range(-attack.angle_spread_deg / 2, attack.angle_spread_deg / 2)) 
	var distance = attack.distance_base + randf_range(-attack.distance_spread / 2, attack.distance_spread / 2)
	var position = Vector2.from_angle(angle_rad) * distance
	
	var velocity_magnitude = attack.velocity_base + randf_range(-attack.velocity_spread / 2, attack.velocity_spread / 2)
	var velocity_direction = -position.normalized()
	var velocity = velocity_direction * velocity_magnitude
	
	asteroid_instance.radius = attack.asteroid.radius
	asteroid_instance.texture = attack.asteroid.texture
	asteroid_instance.mass = attack.asteroid.mass
	asteroid_instance.position = position
	asteroid_instance.time_to_live = attack.asteroid_time_to_live_base + randf_range(-attack.asteroid_time_to_live_spread / 2, attack.asteroid_time_to_live_spread / 2)
	asteroid_instance.linear_velocity = velocity
	asteroid_instance.health = attack.asteroid.health
	asteroid_instance.damage = attack.asteroid.damage
	asteroid_instance.gravity_strength = attack.asteroid.gravity
	
	get_parent().add_child(asteroid_instance)

func is_spawning_done() -> bool:
	for item in attack_schedule.attack_schedule_items:
		if not item.has_meta("started"):
			return false

	return active_attacks.is_empty()
