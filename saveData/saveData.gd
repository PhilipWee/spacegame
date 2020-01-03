extends Node2D

var level_data = []
var current_level = 0


func _ready():
	#Populate the level data array with the players data for each level
	for i in range(10):
		level_data.append({"unlocked":false,
							"stars":0})
	level_data[0]["unlocked"] = false
