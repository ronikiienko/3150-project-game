extends CanvasLayer

func _on_speed_1_pressed() -> void:
	emit_signal("sim_speed_changed", 0.1)


func _on_speed_2_pressed() -> void:
	emit_signal("sim_speed_changed", 0.2)


func _on_speed_3_pressed() -> void:
	emit_signal("sim_speed_changed", 0.5)


func _on_speed_4_pressed() -> void:
	emit_signal("sim_speed_changed", 1.0)
	
var guns: Array[Gun]

@export var guns_selectoin_container: Container

func update_available_guns(guns: Array[Gun]):	
	for child in guns_selectoin_container.get_children():
		child.queue_free()
		
	var group := ButtonGroup.new()
	# Add new buttons
	for i in guns.size():
		var gun = guns[i]
		
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(100.0, 0.0)
		btn.text = gun.name()
		btn.toggle_mode = true
		btn.button_group = group
		btn.connect("pressed", Callable(self, "_on_gun_button_pressed").bind(i))

		guns_selectoin_container.add_child(btn)

func _on_gun_button_pressed(new_gun: int):
	emit_signal("gun_switched", new_gun)

@export var mag_label: Label
@export var inventory_label: Label
@export var health_label: Label

func update_magazine(left: int, size: int):
	mag_label.text = str(left) + " / " + str(size)
	
func update_inventory(left: int):
	inventory_label.text = str(left)

func update_health(left: int, full: int):	
	health_label.text = str(left) + " / " + str(full)

@export var score_label: Label
func update_score(score: int):
	score_label.text = str(score)

signal gun_switched(new_gun: int)
signal sim_speed_changed(new_speed: float)
