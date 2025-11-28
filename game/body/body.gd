extends RigidBody2D
class_name Body

@export var texture: Texture2D;

@export var radius: float;

@onready var _sprite = $Sprite2D as Sprite2D
@onready var _collision_shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tex_size = texture.get_size();
	var target_world_diameter = radius * 2.0;
	var scale_factor = target_world_diameter / tex_size.x;
	_sprite.texture = texture;
	
	_sprite.scale = Vector2(scale_factor, scale_factor);
	add_to_group("bodies")
	if _collision_shape.shape is CircleShape2D:
		_collision_shape.shape.radius = radius;
	
