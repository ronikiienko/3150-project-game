extends Resource
class_name LevelConf

@export var available_guns: Array[GunConf]

@export var attack_schedule: AttackScheduleConf

@export var name: String

@export var world_radius: float = 1000

@export var global_gravity: float = 100

@export var health: int

@export var description: String

@export var camera_speed: float = 800.0

@export var game_speeds: Array[float] = [0.01, 0.05, 0.2, 0.5, 1.0]
@export var default_speed_index: int = 4
