extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(str("FPS: ",(Engine.get_frames_per_second())))


func _process(delta):
	set_text(str("FPS: ",(Engine.get_frames_per_second())))
