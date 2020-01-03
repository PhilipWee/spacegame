extends KinematicBody2D

export var SPEED:float = 0.2
export var CAMERA_SMOOTHING = 200
export var ZOOM_FACTOR = 0.7
export var STARTING_FUEL = 100
export var STARTING_CAM_CENTER = Vector2(2324,1023)
export var STARTING_CAM_ZOOM = 10
export var SHOW_GUIDING_LINE = false
export var PLAYER_MARKER_SIZE = 0.25
export var ENDPOINT_LOCATION = Vector2(2240,2880)
export var LEVEL_NAME = "Insert Level Name"
export var LEVEL_TEXT_FADE_TIME = 3
export var LEVEL_ZOOM_FADE_TIME = 2
export var PREDICTION_DISTANCE = 200
export var SHOW_SPEED_ARROW = true
export var NEXT_LEVEL_STRING: String
export var SHOW_PLAYER_MARKER_AT_ZOOM = 30
export var MAX_DISTANCE_FROM_ENDPOINT = 10000
export var MAX_LANDING_SPEED = 20
export var MUST_LAND_SAFELY = false
export var STAR_3_FUEL:float
export var STAR_2_FUEL:float
export var ZOOM_OFFSET:float = 10

enum shoot_state {STATE_UNREADY,STATE_READY}

onready var joystick_move := $UI/JoystickMove
onready var joystick_shoot := $UI/JoystickShoot
onready var endpoint_marker = $UI/endpointMarker
onready var player_marker = $UI/playerMarker
onready var fuelbar = $UI/fuelBar
onready var level_text = $UI/levelText
onready var speed_marker = $UI/speedMarker
onready var speed_text = $UI/speedMarker/speedText
onready var playArea = $"../playArea"

onready var bullet_scene = preload("res://player/bullet/bullet.tscn")

onready var player_pos = self.get_global_transform_with_canvas()


var vel = Vector2(0,0)
var cam: Camera2D
var projectile_line = Line2D

var current_shoot_state
var last_shoot_output
var endpoint_node

#Make a floatable fuelbar value
var fuel: float
var exists = true
var cam_following = false
var endpoint_on_screen = true
var joystick_enabled = true
var level_completed = false
var show_level_cam = false

#For the show level camera
var camera_rect : = Rect2()
var viewport_rect : = Rect2()

func _rotate_endpoint_marker():
	endpoint_marker.rect_rotation = position.angle_to_point(ENDPOINT_LOCATION) * 180 / PI - 90

func _show_speed_arrow():
	if SHOW_SPEED_ARROW and vel.length() > 1:
		speed_marker.visible = true
		var speed_marker_rotation = vel.angle() * 180 / PI + 90
		speed_marker.rect_rotation = speed_marker_rotation
		if speed_marker_rotation > 180 or speed_marker_rotation < 0:
			speed_text.rect_rotation = 90
		else:
			speed_text.rect_rotation = -90
		
		speed_text.text = String(int(vel.length())) + " m/s"
	else:
		speed_marker.visible = false

func _ready():
	_initialise_fuel()
	_initialise_camera()
	_initialise_projectile_line()
	_create_endpoint()
	_define_viewport_rect()
	_show_starting_text()
	show_level_camera()
	start_zoom_timer()
	
	set_process(get_child_count() > 0)
	

func _define_viewport_rect():
	viewport_rect = get_viewport_rect()

func _show_starting_text():
	level_text.text = LEVEL_NAME
	start_level_text_fade_timer(LEVEL_TEXT_FADE_TIME)

func start_level_text_fade_timer(time):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	timer.connect("timeout", self, "_level_text_fade")
	timer.start()

func _level_text_fade():
	level_text.text = ""

func _create_endpoint():
	var endpoint = preload("res://map/endPoint.tscn").instance()
	get_parent().call_deferred("add_child",endpoint)
	endpoint.position = ENDPOINT_LOCATION
	endpoint.connect("endPoint_entered_screen",self,"_on_endPoint_entered_screen")
	endpoint.connect("endPoint_exited_screen",self,"_on_endPoint_exited_screen")
	endpoint_node = endpoint
	
func _hover_endpoint_marker():
	#TODO: Smooth transition of endpoint marker
	var displacement_of_end = endpoint_node.get_global_transform_with_canvas().get_origin()
	endpoint_marker.anchor_left = 0
	endpoint_marker.anchor_top = 0
	endpoint_marker.rect_position = displacement_of_end
	pass

func _point_to_end_endpoint_marker():
	endpoint_marker.anchor_left = 0.5
	endpoint_marker.anchor_top = 0.08
	endpoint_marker.margin_left = 0
	endpoint_marker.margin_top = 0
	endpoint_marker.visible = true
	pass

func _on_endPoint_entered_screen():
	#Remove the endpoint marker when it is in the screen
#	endpoint_marker.visible = false
	endpoint_on_screen = true

func _on_endPoint_exited_screen():
	#Show the endpoint marker when it is not on the screen
	endpoint_on_screen = false
	

func _initialise_fuel():
	fuel = STARTING_FUEL

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)


func calculate_zoom(rect: Rect2, viewport_size: Vector2) -> Vector2:
	var max_zoom = max(
		max(1, rect.size.x / viewport_size.x + ZOOM_OFFSET),
		max(1, rect.size.y / viewport_size.y + ZOOM_OFFSET))
	return Vector2(max_zoom, max_zoom)

func show_level_camera():
	#TODO: Update to continuously show whole screen
	cam.set_enable_follow_smoothing(CAMERA_SMOOTHING)
	camera_rect = Rect2(position, Vector2()).expand(ENDPOINT_LOCATION)
	cam.position = calculate_center(camera_rect) - position
	cam.zoom = calculate_zoom(camera_rect,viewport_rect.size)
	cam_following = false
	

func start_zoom_timer():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = LEVEL_ZOOM_FADE_TIME
	timer.one_shot = true
	timer.connect("timeout", self, "_zoom_to_character")
	timer.start()
	
func _smooth_zoom_to(zoom_amt):
	var amt_to_add = (zoom_amt - cam.zoom.x)/20
	cam.zoom += Vector2(amt_to_add,amt_to_add)

func _zoom_to_character():
	cam.drag_margin_h_enabled = false
	cam.drag_margin_v_enabled = false
	cam.zoom = Vector2(STARTING_CAM_ZOOM,STARTING_CAM_ZOOM)
	cam_following = true

func _initialise_camera():
	cam = Camera2D.new()
	cam.make_current()
	self.add_child(cam)

func _initialise_projectile_line():
	projectile_line = Line2D.new()
	get_parent().call_deferred("add_child",projectile_line)

func _check_if_out_of_bounds():
	if playArea and self:
		if not playArea.overlaps_body(self):
			die("Out of Bounds")
	
	elif position.distance_to(ENDPOINT_LOCATION) > MAX_DISTANCE_FROM_ENDPOINT:
		die("Out of Bounds")

func _smooth_pan_to(pos:Vector2):
	if cam.position != pos:
		cam.position += (pos-cam.position)/2

#This function handles stuff to do when the cam moves, and moves the cam to the characters smothly
func _handle_cam():
	
	#Add function to show player marker if zoomed out too far
	if cam.zoom.x > SHOW_PLAYER_MARKER_AT_ZOOM:
		player_marker.visible = true
		var player_position_for_canvas = get_global_transform_with_canvas().get_origin()
		player_marker.anchor_top = 0
		player_marker.anchor_bottom = 0 
		player_marker.rect_position = player_position_for_canvas + Vector2(-103,-192) #TODO: change this value when player marker art changes
		pass
	else:
		player_marker.visible = false
			
	if cam_following:
		#If the endpoint is on the screen, place the direction arrow on top of it
		if endpoint_on_screen:
			_hover_endpoint_marker()
		else:
			_point_to_end_endpoint_marker()
		
		#Transition the camera smoothly to the player
		_smooth_pan_to(Vector2.ZERO)
		var zoom_level = vel.length()*ZOOM_FACTOR + 1
		#Zoom to the character depending on the speed
		zoom_level = clamp(zoom_level,1.5,5)
		_smooth_zoom_to(zoom_level)


#----Camera Smoothing Code----
func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference

#Function for resizing the rocket fire
func _handle_rocket_fire(magnitude):
	$rocketFire.scale.y = magnitude

func _handle_rocket_rotation(angle):
	rotation = lerp_angle(rotation,angle + PI/2,0.25)

func _move():

	#----Joystick Movement Code----
	if joystick_move and joystick_move.is_working and fuel > 0 and joystick_enabled:
		fuel -= joystick_move.output.length()
		fuelbar.value = (fuel/STARTING_FUEL) * 1000
		vel += Vector2(joystick_move.output.x*abs(joystick_move.output.x),joystick_move.output.y*abs(joystick_move.output.y)) * SPEED
		#Rotate player depending on joystick input
		_handle_rocket_rotation(joystick_move.output.angle())
		#Scale the rocket fire depending on joystick input
		_handle_rocket_fire(joystick_move.output.length())
	else:
		_handle_rocket_fire(0)
		
	
	#----Gravity Handling Code----
	if  $"../gravityHandler":
		vel += $"../gravityHandler".get_gravity_field(position)
	
	
	#----Collision Handling Code----
	var collision = move_and_collide(vel,false)
	if collision:
		if collision.collider_shape.name == 'NoLandZone':
			#Run Kill Code
			die("Collision With Planet")
		elif collision.collider_shape.name == "LandZone":
			if _check_landing_speed(collision.remainder) == "dead":
				die("Collided too fast")
		elif collision.collider_shape.name == 'EndZone':
			#Run win code
			_win(collision.remainder)
		elif collision.collider_shape.name == 'StartZone':
			if _check_landing_speed(collision.remainder) == "dead":
				die("Collided too fast")
	
	#---- UI Handling Code----
	_rotate_endpoint_marker()
	_generate_line()
	_show_speed_arrow()
	if show_level_cam:
		show_level_camera()
	else:
		_handle_cam()
	
	#----Additional checks for events code----
	_check_if_out_of_bounds()

#If your speed is beyond a certain value on crashing, remove the player
func _check_landing_speed(speed_before_crash):
	if vel.length() > MAX_LANDING_SPEED:
		_remove()
		return "dead"
	else:
		vel = -speed_before_crash
		position += vel
		return "survive"

func die(reason:String):
	if not level_completed:
		var death_scene = preload("res://player/death_scene/DeathOverlay.tscn").instance()
		death_scene.init(reason)
		add_child(death_scene)
		_remove()

func _win(speed_before_landing):
	if MUST_LAND_SAFELY:
		if _check_landing_speed(speed_before_landing) == "dead":
			die("Collided too fast")
			return
	#Load whether you have won or not
	var win_scene = preload("res://player/win_scene/WinOverlay.tscn").instance()
	win_scene.init(NEXT_LEVEL_STRING,"res://menu/menu.tscn")
	add_child(win_scene)
	joystick_enabled = false
	level_completed = true
	#Update the stars
	if fuel > STAR_3_FUEL:
		saveData.level_data[saveData.current_level - 1]["stars"] = 3
	elif fuel > STAR_2_FUEL:
		saveData.level_data[saveData.current_level - 1]["stars"] = 2
	else:
		saveData.level_data[saveData.current_level - 1]["stars"] = 1
	#Unlock the next level
	saveData.level_data[saveData.current_level - 1 + 1]["unlocked"] = true

func _remove():
	exists = false
	$"AnimatedSprite".queue_free()
	$"CollisionShape2D".queue_free()
	$"rocketFire".queue_free()
	projectile_line.queue_free()
	

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
	if SHOW_GUIDING_LINE:
		var points: PoolVector2Array = []
		var current_vel = vel
		var space_state = get_world_2d().get_direct_space_state()
		points.append(position)
		for i in range(1,PREDICTION_DISTANCE):
			points.append(points[-1] + (current_vel))
			current_vel += $"../gravityHandler".get_gravity_field(points[i])
			if space_state.intersect_point(points[-1],1,[],524288).size() > 0:
				break
		projectile_line.points = points



func _physics_process(delta):
	if exists:
		_move()
		_shoot()

func _on_restartButton_pressed():
	get_tree().reload_current_scene()


func _on_menuButton_pressed():
	get_tree().change_scene("res://menu/menu.tscn")
	pass # Replace with function body.


func _on_ViewLevelBtn_button_down():
	show_level_cam = true
	show_level_camera()


func _on_ViewLevelBtn_button_up():
	show_level_cam = false
	_zoom_to_character()

#Use this to debug the show level camera
#func _draw() -> void:
#	draw_rect(camera_rect, Color("#ffffff"), false)
#	draw_circle(calculate_center(camera_rect), 5, Color("#ffffff"))
