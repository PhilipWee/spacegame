extends Node2D

signal endPoint_entered_screen
signal endPoint_exited_screen



func _on_VisibilityNotifier2D_screen_exited():
	emit_signal("endPoint_exited_screen")


func _on_VisibilityNotifier2D_screen_entered():
	emit_signal("endPoint_entered_screen")
