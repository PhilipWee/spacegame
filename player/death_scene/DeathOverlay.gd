extends CanvasLayer

func _ready():
	pass

func init(reason:String):
	$Label.text = "Mission Failed: " + reason
	

func _on_restartButton_pressed():
	get_tree().reload_current_scene()
