extends CanvasLayer

var level_path
var main_menu_path

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(level_to_load,main_menu_scene,information_text=''):
	level_path = level_to_load
	main_menu_path = main_menu_scene
	$MarginContainer/VBoxContainer/InformationText.text = information_text

#If PC can use below code

#func _on_main_menu_pressed():
#	get_tree().change_scene(main_menu_path)
#
#
#func _on_next_level_pressed():
#	get_tree().change_scene(level_path)



func _on_main_menu_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			get_tree().change_scene(main_menu_path)
	pass # Replace with function body.


func _on_next_level_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			get_tree().change_scene(level_path)
	pass # Replace with function body.
