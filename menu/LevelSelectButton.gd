extends Control

export var level_number:int
export var level_to_go_to: String
export var number_of_stars: int = 3
export var unlocked = false

signal level_selected

onready var lock_symbol = $TextureRect2

func init():
	$TextureRect/level_number.text = str(level_number)
	match number_of_stars:
		0:
			$TextureProgress.value = 0
		1:
			$TextureProgress.value = 33
		2:
			$TextureProgress.value = 66
		3:
			$TextureProgress.value = 100
	if unlocked:
		lock_symbol.visible = false
	else:
		lock_symbol.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureRect_pressed():
	if unlocked:
		saveData.current_level = level_number
		get_tree().change_scene(level_to_go_to)
