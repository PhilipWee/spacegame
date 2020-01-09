extends KinematicBody2D

var vel: Vector2
var m:float = 100
var collision

func _ready():
	pass
	
func _move():
		#----Gravity Handling Code----
	if  $"../gravityHandler":
		vel += $"../gravityHandler".get_gravity_field(position)
		#----Collision Handling Code----
	collision = move_and_collide(vel,false)
	if collision:
		if collision.collider_shape.name == 'player':
			#Run the code to get pushed
#			collision.collider.velocity = velocity.length() * 0.5 * -collision.normal
        	vel = vel + vel.bounce(collision.normal) * 1/m

func _get_pushed(collider,remaining_velocity):
	pass

func _check_landing_speed(speed_before_crash):
	vel = -speed_before_crash
	position += vel

func _physics_process(delta):
	_move()

