extends KinematicBody2D

#--------------------------------------------- BASE (MOVEMENT, ACTIONS, COLLISION)  --------------------
export(Color) var col = Color(1,1,1,1)
var input_dir = Vector2()
var input_attack = false
var input_sword = false
var input_axe = false
var input_pickaxe = false
var input_eat = false
var input_build = false
var speed = 1.5
var speed_mod = 1
var base_speed_mod = 1
var on_water = false
var boat = null

onready var b_ray = get_node("body/build_ray")
onready var anim = get_node("anim")
onready var body = get_node("body")
onready var current_tool = get_node("body/hand/tool")
var current_state = "idle"

func _ready():
	get_node("body/sprite").modulate = col
	get_node("hud/health").max_value = max_health
	get_node("hud/hunger").max_value = max_hunger
	set_health(max_health)
	set_hunger(max_hunger)
	
	set_physics_process(false)

func start():
	set_physics_process(true)

func _physics_process(delta):
	input_dir = Vector2()
	input_attack = false
	input_eat = false
	input_build = false
	input_sword = false
	input_axe = false
	input_pickaxe = false
	
	check_input()
	update_health(delta)
	
	if input_build or boat != null:
		b_ray.enabled = true
	else:
		b_ray.enabled = false
	
	if current_state == "eat" or current_state == "build":
		input_dir = Vector2()
		input_attack = false
	
	if tired: 
		base_speed_mod = 0.5
	else:
		base_speed_mod = 1
	
	if on_water:
		if boat == null:
			speed_mod = base_speed_mod * 0.3
		else:
			speed_mod = base_speed_mod * 0.8
	else:
		speed_mod = base_speed_mod
	
	if boat != null:
		if b_ray.is_colliding() and on_water:
			boat.global_position = global_position
	
	var next_state = "idle"
	
	if input_dir != Vector2():
		next_state = "walk"
	
	if input_attack:
		next_state = "attack"
	
	if input_eat and has_food():
		next_state = "eat"
	
	if input_build:
		if input_attack:
			build()
		if input_sword:
			build_tool("character")
		if input_axe:
			build_tool("wood")
		if input_pickaxe:
			build_tool("rock")
	
	if input_sword:
		current_tool.change_tool("character")
	elif input_axe:
		current_tool.change_tool("wood")
	elif input_pickaxe:
		current_tool.change_tool("rock")
	
	var motion = input_dir * speed * speed_mod
	
	move_and_collide(motion)
	
	if motion != Vector2():
		body.look_at(position + motion.normalized())
	
	update_anim_state(next_state)

func check_input():
	pass

func update_anim_state(next_state):
	if current_state == next_state or current_state == "attack" or current_state == "eat":
		return
	
	if next_state == "attack":
		current_tool.attack(self)
	
	anim.play(next_state)
	current_state = next_state

func _on_tile_area_entered( area ):
	if area.is_in_group("water"):
		on_water = true
	elif area.is_in_group("pickable"):
		add_resource(area.resource, area.value)
		area.queue_free()
	else:
		boat = area

func _on_tile_area_exited( area ):
	if area.is_in_group("water"):
		on_water = false
	elif not area.is_in_group("pickable"):
		boat = null

func _on_animation_finished( anim_name ):
	if anim_name == "attack":
		current_tool.finish_attack()
		current_state = ""
		update_anim_state("idle")
	if anim_name == "eat":
		eat_food()
		current_state = ""
		update_anim_state("idle")

func finish(winner):
	set_physics_process(false)
	
	var next_state = "lose"
	if winner:
		next_state = "win"
	
	current_state = ""
	
	update_anim_state(next_state)

#--------------------------------------------  HEALTH   --------------------
enum HUNGER_STATE {HEALTHY, HUNGRY, STARVING}
var tired = false

export var max_health = 10.0
var health = 0.0 setget set_health
var health_regen = 0.1
func set_health(h):
	health = h
	health = clamp(health, 0, max_health)
	
	if health <= 0:
		tired = true
	else:
		tired = false
	
	get_node("hud/health").value = health

export var max_hunger = 10.0
var hunger = 0.0 setget set_hunger
var hunger_state = HUNGER_STATE.HEALTHY
const hunger_loss = 0.3
func set_hunger(h):
	hunger = h
	
	if hunger <= 0:
		hunger = 0
		hunger_state = HUNGER_STATE.STARVING
	elif hunger / max_hunger <= 0.5:
		hunger_state = HUNGER_STATE.HUNGRY
	else:
		hunger_state = HUNGER_STATE.HEALTHY
	
	get_node("hud/hunger").value = hunger

func update_health(delta):
	var loss = hunger_loss * delta
	
	if current_state == "walk" or current_state == "attack":
		loss *= 2
	
	set_hunger(hunger - loss)
	
	if hunger_state == HUNGER_STATE.HUNGRY:
		set_health(health - (hunger_loss * delta))
	elif hunger_state == HUNGER_STATE.STARVING:
		set_health(health - (hunger_loss * delta * 2))
	else:
		set_health(health + (hunger_loss * delta * 2))

func receive_damage(dmg):
	set_health(health - dmg)
#-------------------------------------------- RESOURCES --------------------
var resources = { food = 0, wood = 0, rock = 0 }

# TOOL cost = 5 wood, 5 rock

func add_resource(id, value):
	resources[id] += value
	get_node("hud/resources/" + id).text = str(resources[id])

func has_food():
	return resources["food"] > 0

func eat_food():
	add_resource("food", -1)
	set_hunger(hunger + 1)

func build_tool(id):
	if current_tool.has_tool(id):
#		get_node("hud/warning").already_built()
		return
	
	if resources["wood"] < 5:
		get_node("hud/warning").missing_resource("wood")
		return
	
	if resources["rock"] < 5:
		get_node("hud/warning").missing_resource("rock")
		return
	
	add_resource("wood", -5)
	add_resource("rock", -5)
	current_tool.add_tool(id)

# BOAT cost = 20 wood
func build():
	if resources["wood"] < 20:
		get_node("hud/warning").missing_resource("wood")
		return
	
	if not b_ray.is_colliding():
		get_node("hud/warning").warn("Face the water to build a boat!")
	else:
		var tile = b_ray.get_collider()
		
		if tile.is_in_group("water"):
			var bt = load("res://Assets/Scenes/boat.tscn").instance()
			tile.add_child(bt)
			bt.global_position = b_ray.get_collision_point()
			
			add_resource("wood", -20)
		else:
			get_node("hud/warning").warn("There is already a boat here!")
	
	