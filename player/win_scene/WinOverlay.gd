extends CanvasLayer

var level_path
var main_menu_path

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(level_to_load,main_menu_scene):
	level_path = level_to_load
	main_menu_path = main_menu_scene


func _on_main_menu_pressed():
	get_tree().change_scene(main_menu_path)


func _on_next_level_pressed():
	get_tree().change_scene(level_path)

