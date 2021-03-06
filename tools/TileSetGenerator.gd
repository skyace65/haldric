tool
extends Node

const CODE := {
	"grass-green":           "Gg",
	"void-void":             "Xv",
	"grass-dry":             "Gd",
	"grass-semi-dry":        "Gs",
	"grass-leaf-litter":     "Gll",
	"hills-desert":          "Hd",
	"hills-regular":         "Hh",
	"hills-dry":             "Hhd",
	"hills-snow":            "Ha",
}

var transition_table := {}

export var generate := false setget _set_generate

export var images_path := "res://graphics/images/terrain/transitions"
export var save_path := "res://graphics/tilesets/transitions.tres"

func _set_generate(value):
	if Engine.is_editor_hint():
		_generate_tile_set()

func _generate_tile_set():
	var Loader: Node = preload("res://source/global/Loader.gd").new()

	for transition in Loader.load_dir(images_path, ["png"]):
		var id_str = transition.id.split("_")
		var path_str = transition.path.split("/")

		var name: String = id_str[0]
		var direction: String = id_str[1]
		var parent_folder: String = path_str[path_str.size() - 2]
		var terrain_code: String = CODE["%s-%s" % [parent_folder, name]]

		if not transition_table.has(terrain_code):
			transition_table[terrain_code] = {}

		transition_table[terrain_code][direction] = transition.data

	var tile_set := TileSet.new()

	var id := 0

	for terrain in transition_table:
		for direction in transition_table[terrain]:
			var tile_name = terrain + "_" + direction
			var tile_texture = transition_table[terrain][direction]

			tile_set.create_tile(id)
			tile_set.tile_set_name(id, tile_name)
			tile_set.tile_set_texture(id, tile_texture)
			id += 1

	ResourceSaver.save(save_path, tile_set)
