extends CanvasLayer

var level_path
var main_menu_path
var show_ads = false
onready var stars_bar = $MarginContainer/VBoxContainer/TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(level_to_load,main_menu_scene,stars,information_text='',ads = false):
	show_ads = ads 
	level_path = level_to_load
	main_menu_path = main_menu_scene
	match stars:
		0:
			stars_bar.value = 0
		1:
			stars_bar.value = 33
		2:
			stars_bar.value = 66
		3:
			stars_bar.value = 100
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
			if show_ads:
				saveData.show_ad_interstitial()
			get_tree().change_scene(level_path)
	pass # Replace with function body.
