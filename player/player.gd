extends KinematicBody2D

export var speed = 1

onready var joystick_move := $UI/JoystickMove

var vel = Vector2.ZERO

func _move():
	
	#----Joystick Movement Code----
	if joystick_move and joystick_move.is_working:
		vel += joystick_move.output * speed
	#----Joystick Movement Code----
	
	#----Gravity Handling Code----
	vel += $"../gravityHandler".get_gravity_field(position)
	
	
	#----Collision Handling Code----
	var collision = move_and_collide(vel)
	if collision:
		vel = Vector2.ZERO
	#----Collision Handling Code----

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	_move()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
