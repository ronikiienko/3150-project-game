extends RigidBody2D

@export var radius: float = 10.0;

@onready var collision = $Collision;
@onready var visual = $Visual;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if collision.shape is CircleShape2D:
		collision.shape.radius = radius;
		
	visual.radius = radius;
