extends Node
class_name AttackSystem

@export var attack_schedule: AttackScheduleConf

# Internal state
var current_time: float = 0.0
var active_attacks: Array = []

var _asteroid_scene = preload("res://game/attack_system/asteroid.tscn")

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
	#print("Starting attack: %s at time %.2f" % [item.attack.asteroid.name, current_time])

# Trigger the actual attack (spawn asteroids, bullets, etc.)
func trigger_attack(attack: AttackConf) -> void:
	#print("Triggering attack: %s (instance %d/%d)" % [attack.asteroid.name, 1, attack.count])
	# Example: spawn one asteroid here
	var asteroid_instance = _asteroid_scene.instantiate() as Asteroid
	asteroid_instance.radius = attack.asteroid.radius
	asteroid_instance.texture = attack.asteroid.texture
	asteroid_instance.mass = attack.asteroid.mass
	asteroid_instance.position = Vector2(0.0, 100.0)
	asteroid_instance.apply_force(Vector2(0.0, -200.0))
	
	get_parent().add_child(asteroid_instance)
