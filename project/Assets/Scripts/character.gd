extends KinematicBody2D

var id_number = -1

var input_dir = Vector2()
var speed = 4
var speed_mod = 1

var current_lap = -1

func end_lap():
	current_lap += 1
	

func _physics_process(delta):
	check_input()
	
	var motion = input_dir * speed * speed_mod
	
	move_and_collide(motion)
	
	if motion != Vector2():
		look_at(position + motion.normalized())

func check_input():
	input_dir = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		input_dir.y = -1
	elif Input.is_action_pressed("ui_down"):
		input_dir.y = 1
	
	if Input.is_action_pressed("ui_left"):
		input_dir.x = -1
	elif Input.is_action_pressed("ui_right"):
		input_dir.x = 1


func _on_tile_area_entered( area ):
	if area.is_in_group("water"):
		speed_mod = 0.2
#	elif area.is_in_group("rock"):
#		print("breakable rock!")
##		var bds = get_node("area").get_overlapping_bodies()
##
##		for b in bds:
#		area.clean_tile(global_position)


func _on_tile_area_exited( area ):
	if area.is_in_group("water"):
		speed_mod = 1
