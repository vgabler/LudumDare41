extends Node

const COUNTDOWN_TIME = 4

var timer = COUNTDOWN_TIME + 1
var second = 0

var race_over = false
var race_started = false
var countdown = true
var race_time = 0
onready var finish_position = get_node("environment/finish_line").position

func _ready():
	set_process(true)

func _process(delta):
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
					if r.has_method("set_ai_path"):
						r.set_ai_path(get_node("environment").get_walk_path(r.position, finish_position))
					
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
	
	var racers = get_node("racers").get_children()
	for r in racers:
		r.finish(r == body)
	
	get_node("UI/cd_panel/cd_label").text = "Race over!"
	get_node("UI/cd_panel").visible = true
	
	race_over = true
	set_process(false)
	get_node("restart_timer").start()

func _on_restart_timer_timeout():
	get_tree().reload_current_scene()
