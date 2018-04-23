extends Node

var pickable_object = preload("res://Assets/Scenes/pickable.tscn")
var menu_theme

func _ready():
	menu_theme = AudioStreamPlayer.new()
	menu_theme.stream = load("res://Assets/Audio/menu_theme.wav")
	menu_theme.volume_db = -10
	add_child(menu_theme)
	menu_theme.play()
	
	randomize()

func to_title():
	change_scene("title")

func change_scene(name):
	if name == "main" or name == "main2": 
		menu_theme.stop()
	elif not menu_theme.playing:
		menu_theme.play()
	
	get_tree().change_scene("res://Assets/Screens/%s.tscn" % name)
	
	