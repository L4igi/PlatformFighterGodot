extends State

class_name AirTechState

var airTechInvincibilityFrames = 25.0

func _ready():
	create_invincibility_timer(airTechInvincibilityFrames)

func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.jumpCount = 1
	manage_tech_animation()
	
func manage_tech_animation():
	play_animation("techair")
		
func manage_buffered_input():
	manage_buffered_input_air()
		
func handle_input():
	pass

func handle_input_disabled():
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if animationFramesLeft <= character.bufferInputWindow\
	&& bufferedInput == null: 
		.buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP, true)
		

