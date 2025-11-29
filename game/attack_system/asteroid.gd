extends Body
class_name Asteroid

@export var health: int
@export var damage: int
@export var time_to_live: float

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.body_entered.connect(_on_body_entered)
	add_to_group("asteroids")
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	

func _on_body_entered(body: Node) -> void:
	if body is Bullet or body is Asteroid:
		body.take_damage(damage)
		
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
