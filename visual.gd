extends Node2D

var radius: float = 0.0;

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.5, 0.8))
