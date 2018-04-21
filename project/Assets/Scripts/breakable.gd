extends StaticBody2D

var durability = 0 setget set_durability

var max_durability = 10
var resource = "rock"
var value = 0
var frame_offset = 0
var frame_rate = 0.0
onready var sprite = get_node("sprite")

func _ready():
	if resource == "wood":
		frame_offset = 4
	
	frame_rate = max_durability / 4.0
	
	sprite.frame = frame_offset
	
	add_to_group(resource)
	value = randi()%4
	set_durability(max_durability)

func receive_damage(dmg):
	set_durability(durability - dmg)

func set_durability(h):
	durability = h
	
	var next_frame = clamp(frame_offset + 4 - (durability / frame_rate),0, 7)
	sprite.frame = next_frame
	
	if durability <= 0:
		durability = 0
		die()
	
#	emit_signal("on_durability_changed", durability)

func die():
	drop()
	queue_free()

func drop():
	if value <= 0:
		return
	
	var a = Global.pickable_object.instance()
	a.resource = resource
	a.value = value
	get_parent().add_child(a)
	a.global_position = global_position