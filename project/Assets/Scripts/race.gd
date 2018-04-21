extends Node

const COUNTDOWN_TIME = 4

var timer = COUNTDOWN_TIME + 1
var second = 0

var race_over = false

func _ready():
	set_process(true)

func _process(delta):
	second -= delta
	
	if second <= 0:
		second = 1
		timer -= 1
		
		var text = "%d" % (timer - 1)
		
		if timer == 1:
			text = "Go!"
			var racers = get_node("racers").get_children()
			for r in racers:
				r.start()
		
		get_node("UI/cd_panel/cd_label").text = text
		
		if timer <= 0:
			get_node("UI/cd_panel").visible = false
			set_process(false)

func _on_finish_line_body_entered( body ):
	if race_over:
		return
	
	var racers = get_node("racers").get_children()
	for r in racers:
		r.finish(r == body)
	
	get_node("UI/cd_panel/cd_label").text = "Race over!"
	get_node("UI/cd_panel").visible = true
	
	race_over = true
	get_node("restart_timer").start()

func _on_restart_timer_timeout():
	get_tree().reload_current_scene()
