extends SpecialGround

class_name SpecialGroundMario

func handle_input_disabled():
	match character.currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass
	print("special input ground disbaled input mario")
