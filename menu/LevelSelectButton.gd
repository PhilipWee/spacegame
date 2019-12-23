extends Control

export var level_number:int

signal level_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect/level_number.text = str(level_number)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureRect_pressed():
	get_tree().change_scene("res://map/level1/lvl1.tscn")
