extends CanvasLayer


func _ready():
	pass

func init(reason:String):
	$MarginContainer/VBoxContainer/Label.text = "Mission Failed: " + reason
	

#IF PC

#func _on_restartButton_pressed():
#	get_tree().reload_current_scene()


func _on_restartButton_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			get_tree().reload_current_scene()
	pass # Replace with function body.
