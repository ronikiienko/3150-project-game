extends Control

@export var game_scene: PackedScene
@export var levels_container: Container
@export_dir var levels_dir_path

func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
				
		
func _ready() -> void:
	var levels: Array[LevelConf] = []
	for path in get_all_file_paths(levels_dir_path):
		if not path.ends_with(".tres"):
			continue
		var res = load(path)
		if not res is LevelConf:
			continue
		levels.push_back(res)
		
	for level in levels:
		var button = Button.new()
		button.text = level.name
		button.pressed.connect(Callable(self, "_start_level").bind(level))  # pass the specific LevelConf
		levels_container.add_child(button)

func _start_level(level: LevelConf):
	var instance = game_scene.instantiate()
	instance.level_conf = level  # set your data
	
	# Replace current scene with the new one
	get_tree().get_current_scene().queue_free()  # remove current
	get_tree().root.add_child(instance)          # add new scene
	get_tree().set_current_scene(instance)
