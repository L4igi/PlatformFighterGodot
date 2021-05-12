extends SpecialAir

class_name SpecialAirMario

var downSpecialMaxSpeed = 800
var downSpecialRehitFrames = 5.0

func handle_input_disabled(_delta):
	match character.currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			process_up_special_inputs(_delta)
		GlobalVariables.CharacterAnimations.NSPECIAL:
			process_neutral_special_inputs_charge_shot(_delta)
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			process_down_special_inputs(_delta)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass
	.handle_input_disabled(_delta)
#	print("special input air disbaled input mario")

func process_up_special_inputs(_delta):
	if !hitlagTimer.get_time_left():
		var xInput = get_input_direction_x()
		var walk = character.airMaxSpeed * xInput
		character.velocity.x += (walk * _delta) *4

func process_down_special_inputs(_delta):
	if character.disableInputDI:
		if !hitlagTimer.get_time_left():
			var xInput = get_input_direction_x()
			var walk = character.airMaxSpeed * xInput
			character.velocity.x += (walk * _delta) *10
			character.velocity.x = clamp(character.velocity.x, -downSpecialMaxSpeed, downSpecialMaxSpeed)
	if character.enableSpecialInput:
		if Input.is_action_just_pressed(character.special):
			if character.velocity.y > 0: 
				character.velocity.y -= 700
			else:
				character.velocity.y -= 350
		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
			character.set_collision_mask_bit(1,true) 

func process_neutral_special_inputs_charge_shot(_delta):
	if character.enableSpecialInput:
		if !character.cancelChargeTransition:
			if Input.is_action_just_pressed(character.attack)\
			|| Input.is_action_just_pressed(character.special):
				if character.chargingProjectile:
					character.chargingProjectile.shoot_charge_projectile()
			elif Input.is_action_pressed(character.shield):
				if character.airdodgeAvailable:
					character.cancelChargeTransition = GlobalVariables.CharacterAnimations.AIRDODGE
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
			elif Input.is_action_pressed(character.jump):
				if character.jumpCount < character.availabelJumps:
					character.moveAirGroundTransition.erase(character.currentAttack)
					character.moveGroundAirTransition.erase(character.currentAttack)
					character.cancelChargeTransition = GlobalVariables.CharacterAnimations.DOUBLEJUMP
					if character.chargingProjectile:
						character.chargingProjectile.store_charged_projectile()
			
func on_hitlag_timeout():
	if character.currentAttack == GlobalVariables.CharacterAnimations.DOWNSPECIAL:
		create_rehit_timer(downSpecialRehitFrames)
	.on_hitlag_timeout()
