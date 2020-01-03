extends "res://objects/object.gd"
export var SHOW_GUIDING_LINE = true
export var PREDICTION_DISTANCE = 1000

var done = false

var projectile_line

#TODO: Fix getting into orbit
#TODO: Show Guidance Line
#TODO: Refactor to make player, asteroids inheirt from same object.gd base

func _ready():
	linear_velocity = Vector2(100,0)
	_initialise_projectile_line()
	pass
	
func _initialise_projectile_line():
	projectile_line = Line2D.new()
	get_parent().call_deferred("add_child",projectile_line)
	
func _physics_process(delta):
#	if not done:
#		print('hi')
#		if $"../gravityHandler":
#			done = true
#			vel = $"../gravityHandler".get_orbit_velocity(position)
		
	_generate_line()

func _generate_line():
	print(vel)
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

func _on_object2_body_entered(body):
	pass
