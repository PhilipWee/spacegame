extends Node2D

func _ready():
	pass
	
func _process(delta):
	update()

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

#Use this to debug the show level camera
#func _draw() -> void:
#	draw_rect($player.camera_rect, Color("#ffffff"), false)
#	draw_circle(calculate_center($player.camera_rect), 5, Color("#ffffff"))