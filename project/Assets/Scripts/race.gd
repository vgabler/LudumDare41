extends Node

export var is_two_players = false

const COUNTDOWN_TIME = 4

var timer = COUNTDOWN_TIME + 1
var second = 0

var race_over = false
var race_started = false
var countdown = true
var race_time = 0
var finish_position setget , get_finish_position

func get_finish_position():
	return get_node("environment/finish_line").position

func _ready():
	set_process(true)
	
	if not is_two_players:
		return
		
	get_node("duble_camera").start(get_node("racers/player"),get_node("racers/player2"))

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		Global.to_title()
	
	if countdown == true:
		second -= delta
		
		if second <= 0:
			second = 1
			timer -= 1
			
			var text = "%d" % (timer - 1)
			
			if timer == 1:
				text = "Go!"
				var racers = get_node("racers").get_children()
				race_started = true
				for r in racers:
					r.start()
				
				get_node("UI/cd_panel/beep2").play()
			elif timer > 0:
				get_node("UI/cd_panel/beep1").play()
			
			get_node("UI/cd_panel/cd_label").text = text
			
			if timer <= 0:
				get_node("UI/cd_panel").visible = false
				countdown = false
	
	if not race_started:
		return
	
	race_time += delta
	get_node("UI/time/race_time").text = "%0.2f" % race_time 

func _on_finish_line_body_entered( body ):
	if race_over:
		return
	get_node("bg_track").stop()
	get_node("end_track").play()
	
	var racers = get_node("racers").get_children()
	for r in racers:
		r.finish(r == body)
	
	get_node("UI/cd_panel/cd_label").text = "Finish!"
	get_node("UI/cd_panel").visible = true
	
	race_over = true
	set_process(false)
	get_node("restart_timer").start()

func _on_restart_timer_timeout():
	get_tree().reload_current_scene()
