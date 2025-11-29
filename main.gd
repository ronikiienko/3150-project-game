extends Control

func _start_game():
	get_tree().change_scene_to_file("res://choose_level.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	_start_game()
	

func _input(event: InputEvent):
	if event.is_action_pressed("start_game"):
		_start_game()
			
