extends KinematicBody2D

export var speed = 1

enum shoot_state {STATE_UNREADY,STATE_READY}

onready var joystick_move := $UI/JoystickMove
onready var joystick_shoot := $UI/JoystickShoot

onready var bullet_scene = preload("res://player/bullet/bullet.tscn")


var vel = Vector2.ZERO
var current_shoot_state
var last_shoot_output

func _move():
	
	#----Joystick Movement Code----
	if joystick_move and joystick_move.is_working:
		vel += joystick_move.output * speed
	
	
	#----Gravity Handling Code----
	if  $"../gravityHandler":
		vel += $"../gravityHandler".get_gravity_field(position)
	
	
	#----Collision Handling Code----
	var collision = move_and_collide(vel)
	if collision:
		vel = Vector2.ZERO


func _shoot():
	
	#----Shooting handling Code----
	if joystick_shoot and joystick_shoot.is_working:
		current_shoot_state = shoot_state.STATE_READY
	
	if current_shoot_state == shoot_state.STATE_READY and not joystick_shoot.is_working:
		current_shoot_state = shoot_state.STATE_UNREADY
		_create_bullet(position,last_shoot_output)
	
	if joystick_shoot.output == Vector2.ZERO:
		current_shoot_state = shoot_state.STATE_UNREADY
	
	last_shoot_output = joystick_shoot.output

func _create_bullet(bullet_pos:Vector2,bullet_vel:Vector2):
	var bullet = bullet_scene.instance()
	get_parent().get_node("holders").get_node("bullets").add_child(bullet)
	bullet.create(bullet_pos,bullet_vel,vel)
	
	

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	_move()
	_shoot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
