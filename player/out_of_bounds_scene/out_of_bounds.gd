extends CanvasLayer

var alpha = [0,1]

func _run_tweening():
	$Tween.interpolate_property($Control/Sprite, "modulate", 
	Color(1, 1, 1, alpha[1]), Color(1, 1, 1, alpha[0]), 1.0, 
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _toggle_visibility():
	alpha.invert()
	_run_tweening()
	

func _ready():
	_run_tweening()

func _on_Tween_tween_completed(object, key):
	_toggle_visibility()
