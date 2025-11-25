extends CanvasLayer



func _unpause():
	self.visible = false
	get_tree().paused = false
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == Key.KEY_ESCAPE:
			print("Unpause")
			_unpause()
	

func _on_resume_pressed() -> void:
	_unpause()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://sandbox_config.tscn")
