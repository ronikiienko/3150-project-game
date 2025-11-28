extends Body
class_name Asteroid

@export var contacts_to_live: int = 10
@export var time_to_live: float = 100.0

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_to_group("asteroids")
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func _on_body_entered(body: Node) -> void:
	print("On body entered")
	contacts_to_live -= 1
	if contacts_to_live <= 0:
		queue_free()
