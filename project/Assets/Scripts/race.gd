extends Node

var racers_laps = []
var max_laps = 2

func _ready():
	var racers = get_node("racers").get_children()
	pass

func _on_racer_cross_line( racer ):
	racers_laps[racer.id_number] += 1
	
	if racers_laps[racer.id_number] >= max_laps:
		print("Race finished!")
