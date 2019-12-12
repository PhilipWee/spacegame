extends KinematicBody2D

export var bullet_speed = 5

var gravity_node
var vel = Vector2.ZERO
var touching_parent = true

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_node = get_tree().get_nodes_in_group("gravityHandler")[0]

#For giving the bullet some of that INITIAL VELOCITY
func create(pos:Vector2,new_vel:Vector2,firer_vel:Vector2) -> void:
	position = pos
	vel = new_vel * bullet_speed + firer_vel

func _move():
	#----Gravity Handling Code----
	if gravity_node:
		vel += gravity_node.get_gravity_field(position)
	
	#----Collision Handling Code----
	var collision = move_and_collide(vel)
	if collision:
		vel = Vector2.ZERO

func _physics_process(delta):
	_move()
	

