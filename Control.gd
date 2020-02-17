extends Control

func _ready():
	pass


func _on_Button_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			get_tree().change_scene("res://menu/menu.tscn")
