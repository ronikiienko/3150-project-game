extends Body

@export var time_to_live: float = 20.0
@export var contacts_to_live: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()
	


func _on_body_entered(body: Node) -> void:
	contacts_to_live -= 1
	if contacts_to_live <= 0:
		queue_free()
