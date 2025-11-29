extends Body
class_name Bullet

@export var time_to_live: float
@export var health: int
@export var damage: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.body_entered.connect(_on_body_entered)
	add_to_group("bullets")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_body_entered(body: Node) -> void:
	if body is Asteroid or body is Bullet:
		body.take_damage(damage)
		
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
