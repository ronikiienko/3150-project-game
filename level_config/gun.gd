extends Resource
class_name GunConf

@export var name: String
@export_range(0.01, 100) var bps: float
@export_range(0.0, 360) var spread_degrees: float
@export var impulse: float
@export var mag_size: int
@export var full_reload_time: float
@export var icon: Texture2D
@export var bullet: BulletConf
@export var bullets_available: int = 0
@export var texture: Texture2D
@export var size: float = 1
@export var rotation_speed_degrees: float
