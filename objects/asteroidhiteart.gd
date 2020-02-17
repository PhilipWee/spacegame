extends "res://objects/object.gd"
export var TIME_TO_COLLISION:float = 60
export var INITIAL_VELOCITY = 5
export var OBJECTIVE_NUMBER = 0

var timer
var original_endpoint_location
var timer_running = true

func _ready():
	vel = Vector2.LEFT * INITIAL_VELOCITY
	_start_doomsday_timer(TIME_TO_COLLISION)
	
	

func _physics_process(delta):
	if collision:
		if collision.collider.name == "planet":
			get_parent().get_node("player").die("Asteroid Hit Earth")
	#Constantly reupdate the endpoint to the location of the asteroid
	if timer_running:
		get_parent().get_node("player").ADDITIONAL_CAMERA_VIEWS = [position]
		get_parent().get_node('player').set_information_text("Defend Earth for " + String(ceil(timer.get_time_left())) + " Seconds More")
	else:
		get_parent().get_node("player").ADDITIONAL_CAMERA_VIEWS = []
		get_parent().get_node('player').set_information_text("Return and Land")

func _stop_timer():
	timer_running = false

func _start_doomsday_timer(time):
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	timer.connect("timeout", get_parent().get_node('player'), "objective_completed", [0])
	timer.connect("timeout", self, "_stop_timer")
	timer.start()