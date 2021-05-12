extends SpecialGround

class_name SpecialGroundMario

var downSpecialMaxSpeed = 800
var downSpecialRehitFrames = 5.0

func handle_input_disabled(_delta):
	match character.currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.NSPECIAL:
			process_neutral_special_inputs_charge_shot(_delta)
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
		
func process_neutral_special_inputs_charge_shot(_delta):
	if character.enableSpecialInput:
		if !character.cancelChargeTransition:
			if Input.is_action_just_pressed(character.attack)\
			|| Input.is_action_just_pressed(character.special):
				if character.chargingProjectile:
					character.chargingProjectile.shoot_charge_projectile()
			elif Input.is_action_pressed(character.left):
				character.rollType = character.left
				character.cancelChargeTransition = GlobalVariables.CharacterAnimations.ROLL
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
			elif Input.is_action_pressed(character.right):
				character.rollType = character.right
				character.cancelChargeTransition = GlobalVariables.CharacterAnimations.ROLL
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
			elif Input.is_action_pressed(character.down):
				character.cancelChargeTransition = GlobalVariables.CharacterAnimations.SPOTDODGE
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
			elif Input.is_action_pressed(character.jump):
				character.moveAirGroundTransition.erase(character.currentAttack)
				character.moveGroundAirTransition.erase(character.currentAttack)
				character.cancelChargeTransition = GlobalVariables.CharacterAnimations.JUMP
				if character.chargingProjectile:
					character.chargingProjectile.store_charged_projectile()
	
func on_hitlag_timeout():
	if character.currentAttack == GlobalVariables.CharacterAnimations.DOWNSPECIAL:
		create_rehit_timer(downSpecialRehitFrames)
	.on_hitlag_timeout()
