extends KinematicBody2D

export var SPEED = 2
export var CAMERA_ZOOM = Vector2(3,3)
export var CAMERA_SMOOTHING = 200

enum shoot_state {STATE_UNREADY,STATE_READY}

onready var joystick_move := $UI/JoystickMove
onready var joystick_shoot := $UI/JoystickShoot

onready var bullet_scene = preload("res://player/bullet/bullet.tscn")

signal remove_projectile_line

var vel = Vector2(0,0)
var cam: Camera2D

var current_shoot_state
var last_shoot_output

#Make a floatable fuelbar value
var fuel: float
var exists = true
var cam_following = false

onready var fuelbar = $UI/fuelBar



func _ready():
	fuel =  fuelbar.value
	var center = Vector2(2324,1023)
	var zoom = Vector2(10,10)
	_initialise_camera()
	show_level_camera(center,zoom)

func show_level_camera(center:Vector2,zoom:Vector2):
	cam.set_enable_follow_smoothing(CAMERA_SMOOTHING)
	cam.position = center
	cam.zoom = zoom
	start_zoom_timer(1)

func start_zoom_timer(time):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	timer.connect("timeout", self, "_zoom",[CAMERA_ZOOM])
	timer.start()

func _zoom(zoom_amt):
	cam.position = position
	cam.zoom = zoom_amt
	cam_following = true

func _initialise_camera():
	cam = Camera2D.new()
	cam.make_current()
	get_parent().call_deferred("add_child",cam)

func _handle_cam():
	if cam_following:
		cam.position = position

func _move():
	_generate_line()
	_handle_cam()
	#----Joystick Movement Code----
	if joystick_move and joystick_move.is_working and fuel > 0:
		fuel -= joystick_move.output.length()
		fuelbar.value = fuel
		vel += Vector2(joystick_move.output.x*abs(joystick_move.output.x),joystick_move.output.y*abs(joystick_move.output.y)) * SPEED

	
	#----Gravity Handling Code----
	if  $"../gravityHandler":
		vel += $"../gravityHandler".get_gravity_field(position)
	
	
	#----Collision Handling Code----
	var collision = move_and_collide(vel)
	if collision:
		if collision.collider_shape.name == 'NoLandZone':
			#Run Kill Code
			_die()
		elif collision.collider_shape.name == "LandZone":
			vel = Vector2.ZERO
		elif collision.collider_shape.name == 'EndZone':
			#Run win code
			_win()
		elif collision.collider_shape.name == 'StartZone':
			vel = Vector2.ZERO
			
func _die():
	
	var death_scene = preload("res://player/death_scene/DeathOverlay.tscn").instance()
	add_child(death_scene)
	_remove()

func _win():
	var win_scene = preload("res://player/win_scene/WinOverlay.tscn").instance()
	win_scene.init("res://map/map.tscn","res://menu/menu.tscn")
	add_child(win_scene)
	_remove()

func _remove():
	exists = false
	self.get_node("AnimatedSprite").queue_free()
	self.get_node("CollisionShape2D").queue_free()
	self.get_node("projectile_line").queue_free()

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

func _generate_line():
	var points: PoolVector2Array = []
	var current_vel = vel
	var space_state = get_world_2d().get_direct_space_state()
	points.append(position)
	for i in range(1,200):
		points.append(points[-1] + (current_vel))
		current_vel += $"../gravityHandler".get_gravity_field(points[i])
		if space_state.intersect_point(points[-1],1,[],524288).size() > 0:
			break
	for i in range(points.size()):
		points[i] = points[i] - position
	self.get_node('projectile_line').points = points



func _physics_process(delta):
	if exists:
		_move()
		_shoot()

func _on_restartButton_pressed():
	get_tree().reload_current_scene()


func _on_menuButton_pressed():
	get_tree().change_scene("res://menu/menu.tscn")
	pass # Replace with function body.
