extends State

class_name GroundTechState
var groundTechInvincibilityFrames = 25.0

func _ready():
	create_invincibility_timer(groundTechInvincibilityFrames)

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.jumpCount = 0
	manage_tech_animation()
	character.airdodgeAvailable = true
	
func manage_buffered_input():
	manage_buffered_input_ground()
	
func manage_tech_animation():
	if Input.is_action_pressed(character.right):
		play_animation("techroll")
	elif Input.is_action_pressed(character.left):
		play_animation("techroll")
	else:
		play_animation("techground")
		
func handle_input():
	pass

func handle_input_disabled(_delta):
	if !bufferedInput:
		buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		check_stop_area_entered(_delta)
		character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP, true)
		

func check_stop_area_entered(_delta):
	match character.atPlatformEdge:
		GlobalVariables.MoveDirection.RIGHT:
			if character.velocity.x >= 0:
				character.velocity.x = 0
		GlobalVariables.MoveDirection.LEFT:
			if character.velocity.x <= 0:
				character.velocity.x = 0
