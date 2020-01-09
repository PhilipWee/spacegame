extends Node2D
export (PackedScene) var Planet

export var G = 100

var planet_data : PoolVector3Array = []
#Add to the gravity handler group


func _ready():
	$".".add_to_group("gravityHandler")
	var children = get_parent().get_children()
	for child in children:
		if child.get_filename() == Planet.get_path():
			planet_data.append(Vector3(child.position.x,child.position.y,child.get_mass()))

func get_gravity_field(location : Vector2):
	var field = Vector2.ZERO
	for planet in planet_data:
		var magnitude = G * planet.z / pow(location.distance_to(Vector2(planet.x,planet.y)),2.2)
		field += Vector2(magnitude,0).rotated((Vector2(planet.x,planet.y) - location).angle())
	return field
	
func get_orbit_velocity(location : Vector2):
	var magnitude:float = 0
	var direction = get_gravity_field(location).normalized().rotated(PI/2)
	for planet in planet_data:
		magnitude += sqrt(G * planet.z / location.distance_to(Vector2(planet.x,planet.y))) * 0.43
	return direction * magnitude