extends RigidBody2D

var vel: Vector2

func _ready():
	pass
	
func _move():
		#----Gravity Handling Code----
	if  $"../gravityHandler":
	
		#----Collision Handling Code----
		add_central_force($"../gravityHandler".get_gravity_field(position))

func _physics_process(delta):
	_move()

