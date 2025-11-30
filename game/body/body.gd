extends RigidBody2D
class_name Body

@export var texture: Texture2D;

@export var gravity_strength: float
@export var gravity_radius: float

@export var radius: float;

var _sprite: Sprite2D
var _collision_shape: CollisionShape2D
var _collision_circle: CircleShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	
	var tex_size = texture.get_size();
	var target_world_diameter = radius * 2.0;
	var scale_factor = target_world_diameter / tex_size.x;
	_sprite.scale = Vector2(scale_factor, scale_factor);
	add_child(_sprite)
	
	_collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	_collision_shape.shape = circle
	_collision_circle = circle
	add_child(_collision_shape)
	
	contact_monitor = true
	max_contacts_reported = 1
	
	add_to_group("bodies")
	
