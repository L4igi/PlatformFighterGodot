extends State

class_name GetUpState

func _ready():
	pass

func _process(delta):
	var direction = 1
	if character.currentMoveDirection == Globals.MoveDirection.LEFT: 
		direction = -1
	manage_getup_animation(character.getUpType, direction)
	character.getUpType = null
	
func manage_buffered_input():
	manage_buffered_input_ground()
	
func handle_input(_delta):
	pass

func handle_input_disabled(_delta):
	if!bufferedInput:
		buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		check_stop_area_entered(_delta)
		process_movement_physics(_delta)
	
func manage_getup_animation(getUpType, direction):
	character.getUpType = getUpType
	match getUpType: 
		Globals.CharacterAnimations.ROLLGETUP:
			play_animation("roll_getup")
		Globals.CharacterAnimations.NORMALGETUP:
			play_animation("normal_getup")
		Globals.CharacterAnimations.ATTACKGETUP:
			play_attack_animation("attack_getup")
			character.currentAttack = Globals.CharacterAnimations.ATTACKGETUP


func check_stop_area_entered(_delta):
	match character.atPlatformEdge:
		Globals.MoveDirection.RIGHT:
			match character.currentMoveDirection:
				Globals.MoveDirection.LEFT:
					pass
				Globals.MoveDirection.RIGHT:
					character.velocity.x = 0
		Globals.MoveDirection.LEFT:
			match character.currentMoveDirection:
				Globals.MoveDirection.LEFT:
					character.velocity.x = 0
				Globals.MoveDirection.RIGHT:
					pass
