extends "res://Assets/Scripts/character.gd"

export var is_player_2 = false
var player_index = "1"

func _ready():
	if is_player_2:
		player_index = "2"

func check_input():
	input_attack = Input.is_action_pressed("attack" + player_index)
	input_build = Input.is_action_pressed("build" + player_index)
	input_eat = Input.is_action_pressed("eat" + player_index)
	input_sword = Input.is_action_pressed("sword" + player_index)
	input_axe = Input.is_action_pressed("axe" + player_index)
	input_pickaxe = Input.is_action_pressed("pickaxe" + player_index)
	
	if Input.is_action_pressed("up" + player_index):
		input_dir.y = -1
	elif Input.is_action_pressed("down" + player_index):
		input_dir.y = 1
	
	if Input.is_action_pressed("left" + player_index):
		input_dir.x = -1
	elif Input.is_action_pressed("right" + player_index):
		input_dir.x = 1