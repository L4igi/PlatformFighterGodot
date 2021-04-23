extends State

class_name ReboundState

var reboundTimer = null 
var reboundFrames = 0.0

func _ready():
	hitlagTimer.stop()
	create_hitlag_timer(character.bufferReboundFrames)
	
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	
func _physics_process(delta):
	print("REBOUNDING ")
