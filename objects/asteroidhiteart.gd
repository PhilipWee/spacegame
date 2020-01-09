extends "res://objects/object.gd"
export var TIME_TO_COLLISION:float = 60
export var INITIAL_VELOCITY = 5
export var OBJECTIVE_NUMBER = 0

func _ready():
	vel = Vector2.LEFT * INITIAL_VELOCITY
	_start_doomsday_timer(TIME_TO_COLLISION)
	

func _physics_process(delta):
	if collision:
		if collision.collider.name == "planet":
			get_parent().get_node("player").die("Asteroid Hit Earth")
	#Constantly reupdate the endpoint to the location of the asteroid
	get_parent().get_node("player").ENDPOINT_LOCATION = position

func _start_doomsday_timer(time):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	timer.connect("timeout", get_parent().get_node('player'), "objective_completed", [0])
	timer.start()