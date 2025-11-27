extends Control

@export var game_scene: PackedScene
@export var levels_container: Container
@export var levels: Array[LevelConf]
				
		
func _ready() -> void:
	for level in levels:
		var button = Button.new()
		button.text = level.name
		button.pressed.connect(Callable(self, "_start_level").bind(level))  # pass the specific LevelConf
		levels_container.add_child(button)

func _start_level(level: LevelConf):
	var instance = game_scene.instantiate()
	instance.level_conf = levels[0]  # set your data
	
	# Replace current scene with the new one
	get_tree().get_current_scene().queue_free()  # remove current
	get_tree().root.add_child(instance)          # add new scene
	get_tree().set_current_scene(instance)
