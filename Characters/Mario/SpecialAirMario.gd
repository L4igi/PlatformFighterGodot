extends SpecialAir

class_name SpecialAirMario

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
	print("special input air disbaled input mario")
