extends "res://objects/object.gd"
export var SHOW_GUIDING_LINE = true
export var PREDICTION_DISTANCE = 500
export var INITIAL_VELOCITY_OFFSET = 0


var done = false
var in_orbit = false

var projectile_line

#TODO: Fix getting into orbit
#TODO: Show Guidance Line
#TODO: Refactor to make player, asteroids inheirt from same object.gd base

func _ready():
	_initialise_projectile_line()
	pass

func _initialise_projectile_line():
	projectile_line = Line2D.new()
	get_parent().call_deferred("add_child",projectile_line)

func _physics_process(delta):
	if not done:
		if $"../gravityHandler":
			done = true
			vel = $"../gravityHandler".get_orbit_velocity(position)
			vel += Vector2.RIGHT * INITIAL_VELOCITY_OFFSET
	#Constantly reupdate the endpoint to the location of the asteroid
	get_parent().get_node("player").ENDPOINT_LOCATION = self.position
	_generate_line()

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
		
func set_orbitting(boolean):
	if boolean:
		get_parent().get_node("player").get_node("UI/informationText").text = 'Space Station in Orbit'
		get_parent().get_node("player").objective_completed(0)
	else:
		get_parent().get_node("player").get_node("UI/informationText").text = 'Space Station Out of Orbit'
		get_parent().get_node("player").objective_completed(0,false)


func _on_MustBeIn_body_exited(body):
	if body == self:
		set_orbitting(false)
	

func _on_MustBeIn_body_entered(body):
	if body == self:
		set_orbitting(true)
	

func _on_MustBeOut_body_entered(body):
	if body == self:
		set_orbitting(false)
	

func _on_MustBeOut_body_exited(body):
	if body == self:
		set_orbitting(false)