extends State

class_name ShieldStunState

var shieldStunTimer = null 
#var shieldStunFrames = 0

func _ready():
	shieldStunTimer = create_timer("on_shieldStun_timeout", "ShieldStunTimer")
	create_hitlagAttacked_timer(character.bufferHitLagFrames)

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.disableInput = true 
	character.characterShield.enable_shield()
	CharacterInteractionHandler.remove_ground_colliding_character(character)

#func manage_buffered_input():
#	manage_buffered_input_ground()
#
#func handle_input():
#	pass
#
#func handle_input_disabled(_delta):
#	if !bufferedInput:
#		.buffer_input()

func _physics_process(_delta):
	if !stateDone:
#		handle_input_disabled(_delta)
		process_movement_physics(_delta)
	
func create_shieldStun_timer(waitTime):
	character.disableInput = true
	character.set_collision_mask_bit(0,false)
	start_timer(shieldStunTimer, waitTime)
	
func on_shieldStun_timeout():
	character.shieldStunFrames = 0
	if !Input.is_action_pressed(character.shield):
		character.characterShield.disable_shield()
		character.shieldDropped = true
		character.change_state(GlobalVariables.CharacterState.GROUND)
	else:
		character.change_state(GlobalVariables.CharacterState.SHIELD)
		
func create_hitlagAttacked_timer(waitTime):
	.create_hitlagAttacked_timer(waitTime)
	character.characterShield.pause_shield()
		
func on_hitlagAttacked_timeout():
	.on_hitlag_timeout()
	character.characterShield.unpause_shield()
	character.characterShield.apply_shield_damage()
	if character.characterShield.shieldBreak:
		character.change_state(GlobalVariables.CharacterState.SHIELDBREAK)
	else:
		create_shieldStun_timer(character.shieldStunFrames)
