extends CanvasLayer

#func _on_speed_1_pressed() -> void:
	#Engine.time_scale = 0.1
#
#
#func _on_speed_2_pressed() -> void:
	#Engine.time_scale = 0.2
#
#
#func _on_speed_3_pressed() -> void:
	#Engine.time_scale = 0.5
#
#
#func _on_speed_4_pressed() -> void:
	#Engine.time_scale = 1.0
	
var guns: Array[Gun]

func update_available_guns(guns: Array[Gun]):
	var container = $MarginContainer2/GunsSelection
	
	for child in container.get_children():
		child.queue_free()
		
	var group := ButtonGroup.new()
	# Add new buttons
	for i in guns.size():
		var gun = guns[i]
		
		var btn := Button.new()
		btn.text = gun.gun_name
		btn.toggle_mode = true
		btn.button_group = group
		btn.connect("pressed", Callable(self, "_on_gun_button_pressed").bind(i))

		container.add_child(btn)

func _on_gun_button_pressed(new_gun: int):
	emit_signal("gun_switched", new_gun)
	
func update_bullet_state(in_mag: int, mag_size: int):
	var in_mag_label = $Container/InMag
	var mag_size_label = $Container/MagSize
	
	in_mag_label.text = str(in_mag) 
	mag_size_label.text = str(mag_size)

signal gun_switched(new_gun: int)
