extends State

class_name InGrabState

func _ready():
	character.characterShield.disable_shield()
	reset_gravity()
	character.chargingSmashAttack = false
	character.smashAttack = null
	character.global_position = character.inGrabByCharacter.interactionPoint.global_position
	character.velocity = Vector2.ZERO
	gravity_on_off("off")
	play_animation("ingrab")
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.disableInput = false
	character.initLaunchVelocity = Vector2.ZERO
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	character.airdodgeAvailable = true

#func _physics_process(_delta):
#	if abs(int(character.inGrabByCharacter.velocity.x)) != 0: 
#		character.global_position = character.inGrabByCharacter.grabPoint.global_position
#	process_movement_physics(_delta)
