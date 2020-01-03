extends Label

#Constantly update the pivot offset to be the center of the text
func _ready():
	pass
	
func _physics_process(delta):
	self.rect_pivot_offset = self.rect_size/2
