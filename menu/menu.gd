extends Control

func _ready():
#	saveData.show_rewarded_video()
	saveData.show_ad_banner()
#	saveData.show_ad_interstitial()
	$debugtext.text = saveData.logs

func _on_levelSelectOld_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var level_select_scene = preload("res://menu/LevelSelect.tscn").instance()
			add_child_below_node($VBoxContainer, level_select_scene)
