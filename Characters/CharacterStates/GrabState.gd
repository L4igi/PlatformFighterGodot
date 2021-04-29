extends State

class_name GrabState

var grabTimer = null

func _ready():
	grabTimer = GlobalVariables.create_timer("on_grabTimer_timeout", "GrabTimer", self)
	play_animation("grab")
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)

func _input(event):
	if character.grabbedCharacter != null && !character.disableInput:
		if event.is_action_pressed(character.attack):
			character.currentAttack = GlobalVariables.CharacterAnimations.GRABJAB
			play_animation("grabjab")
		elif event.is_action_pressed(character.left):
			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				character.currentAttack = GlobalVariables.CharacterAnimations.FTHROW
				play_animation("fthrow")
			else:
				character.currentAttack = GlobalVariables.CharacterAnimations.BTHROW
				play_animation("bthrow")
#			grabTimer.stop_timer()
		elif event.is_action_pressed(character.right):
			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				character.currentAttack = GlobalVariables.CharacterAnimations.FTHROW
				play_animation("fthrow")
			else:
				character.currentAttack = GlobalVariables.CharacterAnimations.BTHROW
				play_animation("bthrow")
#			grabTimer.stop_timer()
		elif event.is_action_pressed(character.up):
			character.currentAttack = GlobalVariables.CharacterAnimations.UTHROW
			play_animation("uthrow")
#			grabTimer.stop_timer()
		elif event.is_action_pressed(character.down):
			character.currentAttack = GlobalVariables.CharacterAnimations.DTHROW
			play_animation("dthrow")
#			grabTimer.stop_timer()
	
func _physics_process(_delta):
	if !stateDone:
		if check_in_air():
			character.disableInput = false
			character.bufferMoveAirTransition = true
			character.change_state(GlobalVariables.CharacterState.AIR)
			if character.grabbedCharacter != null:
				character.grabbedCharacter.on_grab_release()
			
func create_grab_timer(waitTime):
	GlobalVariables.start_timer(grabTimer, waitTime)
	
func on_grabTimer_timeout():
	if character.grabbedCharacter:
		character.grabbedCharacter.on_grab_release()
		character.grabbedCharacter = null
		character.change_state(GlobalVariables.CharacterState.GROUND)
