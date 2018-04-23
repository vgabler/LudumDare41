extends TileMap

export var clear_on_load = false
export var resource = "rock"

func _ready():
	var tiles = get_used_cells()
	var replace_object = load("res://Assets/Scenes/breakable.tscn")
	
	for t in tiles:
		var o = replace_object.instance()
		o.position = map_to_world(t)
		o.resource = resource
		add_child(o)
	
	if clear_on_load:
		clear()