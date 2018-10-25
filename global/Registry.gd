extends Node

var yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()

var units = {}
var abilities = {}
var scenarios = {}

func load_ability_dir(path):
	var files = []
	files = get_files_in_directory(path, files)
	for file in files:
		print(file.file.get_path())
		var script = load(file.file.get_path()).new()
		abilities[file.id] = {}
		abilities[file.id].script = script
		abilities[file.id].function = funcref(script, file.id)

func load_unit_dir(path):
	
	var files = []
	files = get_files_in_directory(path, files)
	for file in files:
		var yaml = yaml_parser.parse(file.file.get_as_text())
		units[yaml.id] = yaml
		if !yaml.has("abilities"):
			units[yaml.id].abilities = []

func load_scenario_dir(path):
	var files = []
	files = get_files_in_directory(path, files)
	for file in files:
		var yaml = yaml_parser.parse(file.file.get_as_text())
		scenarios[yaml.id] = yaml
		scenarios[yaml.id].map_data = MapLoader.load_map(yaml.map_data)

func get_files_in_directory(path, files):
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	var sub_path
	while true:
		sub_path = dir.get_next()
		if sub_path == "." or sub_path == "..":
			continue
		if sub_path == "":
			break
		if dir.current_is_dir():
			get_files_in_directory(dir.get_current_dir() + "/" + sub_path, files)
		else:
			var file = File.new()
			var file_id = sub_path.split(".")[0]
			print("load file: ", dir.get_current_dir() + "/" + sub_path)
			if file.open(dir.get_current_dir() + "/" + sub_path, file.READ) == OK:
				files.append({ file = file, id = file_id })
	dir.list_dir_end()
	return files

func validate_advancements():
	for unit in units.values():
		if !units.has(unit.advances_to) and unit.advances_to != null:
			print(unit.id, ": Invalid Advancement! ", unit.advances_to, " does not exist!")

func create_unit(id, side):
	var unit = load("res://units/Unit.tscn").instance()
	unit.initialize(units[id], side)
	return unit