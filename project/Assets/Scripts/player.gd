extends "res://Assets/Scripts/character.gd"

func check_input():
	input_attack = Input.is_action_pressed("attack")
	input_build = Input.is_action_pressed("build")
	input_eat = Input.is_action_pressed("eat")
	input_sword = Input.is_action_pressed("sword")
	input_axe = Input.is_action_pressed("axe")
	input_pickaxe = Input.is_action_pressed("pickaxe")
	
	if Input.is_action_pressed("ui_up"):
		input_dir.y = -1
	elif Input.is_action_pressed("ui_down"):
		input_dir.y = 1
	
	if Input.is_action_pressed("ui_left"):
		input_dir.x = -1
	elif Input.is_action_pressed("ui_right"):
		input_dir.x = 1