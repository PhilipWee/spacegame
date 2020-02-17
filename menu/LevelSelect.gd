extends Control

onready var grid = $MarginContainer/GridContainer

func _ready():
	#TODO: Fix strange indexing bug
	saveData.level_data[0]['unlocked'] = true
	for level_number in range(1,len(saveData.level_data)+1):
		#Handle each level on the level scene
		var single_level_data = saveData.level_data[level_number-1]
		var level_select_button = preload("res://menu/LevelSelectButton.tscn").instance()
		level_select_button.level_number = level_number
		level_select_button.level_to_go_to = "res://map/levels/lvl"+String(level_number)+".tscn"
		level_select_button.number_of_stars = single_level_data["stars"]
		level_select_button.unlocked = single_level_data["unlocked"]
		grid.add_child(level_select_button)
		
