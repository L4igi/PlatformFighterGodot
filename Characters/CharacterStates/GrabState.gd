extends State

class_name GrabState

var grabTimer = null

func _ready():
	grabTimer = Globals.create_timer("on_grabTimer_timeout", "GrabTimer", self)
	play_animation("grab")
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.currentAttack = Globals.CharacterAnimations.GRAB


func handle_input_disabled(_delta):
	if character.grabbedCharacter != null && !character.disableInput:
		if Input.is_action_just_pressed(character.attack):
			character.currentAttack = Globals.CharacterAnimations.GRABJAB
			play_animation("grabjab")
		elif Input.is_action_just_pressed(character.left):
			if character.currentMoveDirection == Globals.MoveDirection.LEFT:
				character.currentAttack = Globals.CharacterAnimations.FTHROW
				play_animation("fthrow")
			else:
				character.currentAttack = Globals.CharacterAnimations.BTHROW
				play_animation("bthrow")
#			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(character.right):
			if character.currentMoveDirection == Globals.MoveDirection.RIGHT:
				character.currentAttack = Globals.CharacterAnimations.FTHROW
				play_animation("fthrow")
			else:
				character.currentAttack = Globals.CharacterAnimations.BTHROW
				play_animation("bthrow")
#			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(character.up):
			character.currentAttack = Globals.CharacterAnimations.UTHROW
			play_animation("uthrow")
#			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(character.down):
			character.currentAttack = Globals.CharacterAnimations.DTHROW
			play_animation("dthrow")
#			grabTimer.stop_timer()
	
func _physics_process(_delta):
	if !stateDone:
		process_movement_physics(_delta)
		handle_input_disabled(_delta)
		if check_in_air():
			character.disableInput = false
			character.change_state(Globals.CharacterState.AIR)
			if character.grabbedCharacter != null:
				character.grabbedCharacter.on_grab_release()
			
func create_grab_timer(waitTime):
	Globals.start_timer(grabTimer, waitTime)
	
func on_grabTimer_timeout():
	if character.grabbedCharacter:
		character.grabbedCharacter.on_grab_release()
		character.grabbedCharacter = null
		character.change_state(Globals.CharacterState.GROUND)
