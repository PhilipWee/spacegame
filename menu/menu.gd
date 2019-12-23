extends Control

func _on_levelSelect_pressed():
	var level_select_scene = preload("res://menu/LevelSelect.tscn").instance()
	add_child_below_node($VBoxContainer, level_select_scene)
