extends SpecialAir

class_name SpecialAirLink

var downSpecialMaxSpeed = 800
var downSpecialRehitFrames = 5.0

func handle_input_disabled(_delta):
	match character.currentAttack:
		Globals.CharacterAnimations.UPSPECIAL:
			process_up_special_inputs(_delta)
		Globals.CharacterAnimations.NSPECIAL:
			process_neutral_special_inputs(_delta)
		Globals.CharacterAnimations.DOWNSPECIAL:
			pass
		Globals.CharacterAnimations.SIDESPECIAL:
			pass
	.handle_input_disabled(_delta)
#	print("special input air disbaled input mario")

func process_up_special_inputs(_delta):
#	if character.enableSpecialInput:
#		if animationPlayer.is_playing():
#			if Input.is_action_pressed(character.special):
#				animationPlayer.stop(false)
#		else:
#			character.attackMultiplicator += 0.01
#			if !Input.is_action_pressed(character.special):
#				animationPlayer.play()
	if !hitlagTimer.get_time_left() && !character.enableSpecialInput:
		var xInput = get_input_direction_x()
		var walk = character.airMaxSpeed * xInput
		character.velocity.x += (walk * _delta) *4

func process_neutral_special_inputs_charge_shot(_delta):
	if character.enableSpecialInput:
		if !character.cancelChargeTransition:
			if Input.is_action_just_pressed(character.attack)\
			|| Input.is_action_just_pressed(character.special):
				if character.chargingProjectile && !character.animationPlayer.is_playing():
					character.enableSpecialInput = false
					character.chargingProjectile.shoot_charge_projectile()
			elif Input.is_action_just_pressed(character.shield):
				if character.airdodgeAvailable:
					character.enableSpecialInput = false
					character.cancelChargeTransition = Globals.CharacterAnimations.AIRDODGE
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
			elif Input.is_action_just_pressed(character.jump):
				if character.jumpCount < character.availabelJumps:
					character.enableSpecialInput = false
					character.moveAirGroundTransition.erase(character.currentAttack)
					character.moveGroundAirTransition.erase(character.currentAttack)
					character.cancelChargeTransition = Globals.CharacterAnimations.DOUBLEJUMP
					if character.chargingProjectile:
						character.chargingProjectile.store_charged_projectile()
			
func process_neutral_special_inputs(_delta):
	if character.enableSpecialInput:
		if animationPlayer.is_playing():
			if Input.is_action_pressed(character.special):
				animationPlayer.stop(false)
			else:
				character.enableSpecialInput = false
		else:
			character.attackMultiplicator += 0.01
			if !Input.is_action_pressed(character.special):
				animationPlayer.play()
				character.enableSpecialInput = false
			
func on_hitlag_timeout():
	if character.currentAttack == Globals.CharacterAnimations.DOWNSPECIAL:
		create_rehit_timer(downSpecialRehitFrames)
	.on_hitlag_timeout()
