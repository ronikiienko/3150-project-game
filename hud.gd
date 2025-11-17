extends CanvasLayer

func _on_speed_1_pressed() -> void:
	Engine.time_scale = 0.1


func _on_speed_2_pressed() -> void:
	Engine.time_scale = 0.2


func _on_speed_3_pressed() -> void:
	Engine.time_scale = 0.5


func _on_speed_4_pressed() -> void:
	Engine.time_scale = 1.0
