extends SpecialGround

class_name SpecialGroundMario

var downSpecialMaxSpeed = 800
var downSpecialRehitFrames = 5.0

func handle_input_disabled(_delta):
	match character.currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			process_down_special_inputs(_delta)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass
	.handle_input_disabled(_delta)
#	print("special input ground disbaled input mario")


func process_down_special_inputs(_delta):
	if character.disableInputDI:
		if !hitlagTimer.get_time_left():
			var xInput = get_input_direction_x()
			var walk = character.airMaxSpeed * xInput
			character.velocity.x += (walk * _delta) *10
			character.velocity.x = clamp(character.velocity.x, -downSpecialMaxSpeed, downSpecialMaxSpeed)
	if character.enableSpecialInput:
		pass
	
func on_hitlag_timeout():
	if character.currentAttack == GlobalVariables.CharacterAnimations.DOWNSPECIAL:
		create_rehit_timer(downSpecialRehitFrames)
	.on_hitlag_timeout()
