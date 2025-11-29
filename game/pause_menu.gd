extends CanvasLayer	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		emit_signal("toggle_pause")

func _on_resume_pressed() -> void:
	emit_signal("toggle_pause")


func _on_main_menu_pressed() -> void:
	emit_signal("main_menu")


func _on_quit_game_pressed() -> void:
	emit_signal("quit")


func _on_restart_pressed() -> void:
	emit_signal("restart")
	
signal restart()

signal toggle_pause()

signal main_menu()

signal quit()
