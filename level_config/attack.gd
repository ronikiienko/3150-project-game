extends Resource

class_name AttackConf

@export var asteroid: AsteroidConf
@export var interval: float = 1.0
@export var count: int = 5

@export var angle_base_deg: float
@export var angle_spread_deg: float
@export var distance_base: float
@export var distance_spread: float

@export var velocity_base: float
@export var velocity_spread: float

@export var asteroid_time_to_live_base: float
@export var asteroid_time_to_live_spread: float
