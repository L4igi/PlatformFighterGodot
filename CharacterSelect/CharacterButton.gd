extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	print("pressed " +str(get_viewport().get_mouse_position()))
	if is_visible():
		set_visible(false)
	else:
		set_visible(true)
