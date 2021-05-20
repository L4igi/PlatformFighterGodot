extends SpecialGround

class_name SpecialGroundLink

var downSpecialMaxSpeed = 800
var downSpecialRehitFrames = 5.0

func handle_input_disabled(_delta):
	match character.currentAttack:
		Globals.CharacterAnimations.UPSPECIAL:
			process_up_special_inputs(_delta)
		Globals.CharacterAnimations.NSPECIAL:
			process_neutral_special_inputs(_delta)
		Globals.CharacterAnimations.DOWNSPECIAL:
			process_down_special_inputs(_delta)
		Globals.CharacterAnimations.SIDESPECIAL:
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
		
func process_up_special_inputs(_delts):
	if animationPlayer.is_playing():
		if Input.is_action_pressed(character.special):
			animationPlayer.stop(false)
	else:
		character.attackMultiplicator += 0.01
		if !Input.is_action_pressed(character.special):
			animationPlayer.play()
		
func process_neutral_special_inputs_charge_shot(_delta):
	if character.enableSpecialInput:
		if !character.cancelChargeTransition:
			if Input.is_action_just_pressed(character.attack)\
			|| Input.is_action_just_pressed(character.special)\
			|| Input.is_action_just_pressed(character.grab):
				if character.chargingProjectile && !character.animationPlayer.is_playing():
					character.enableSpecialInput = false
					character.chargingProjectile.call_deferred("shoot_charge_projectile")
			elif Input.is_action_just_pressed(character.left):
				if !bReverseTimer.get_time_left():
					character.enableSpecialInput = false
					character.rollType = character.left
					character.cancelChargeTransition = Globals.CharacterAnimations.ROLL
					if character.chargingProjectile:
						character.chargingProjectile.call_deferred("store_charged_projectile")
			elif Input.is_action_just_pressed(character.right):
				if !bReverseTimer.get_time_left():
					character.enableSpecialInput = false
					character.rollType = character.right
					character.cancelChargeTransition = Globals.CharacterAnimations.ROLL
					if character.chargingProjectile:
						character.chargingProjectile.call_deferred("store_charged_projectile")
			elif Input.is_action_just_pressed(character.down):
				character.enableSpecialInput = false
				character.cancelChargeTransition = Globals.CharacterAnimations.SPOTDODGE
				if character.chargingProjectile:
					character.chargingProjectile.call_deferred("store_charged_projectile")
			elif Input.is_action_just_pressed(character.jump):
				character.enableSpecialInput = false
				character.moveAirGroundTransition.erase(character.currentAttack)
				character.moveGroundAirTransition.erase(character.currentAttack)
				character.cancelChargeTransition = Globals.CharacterAnimations.JUMP
				if character.chargingProjectile:
					character.chargingProjectile.call_deferred("store_charged_projectile")
			elif Input.is_action_just_pressed(character.shield):
				character.enableSpecialInput = false
				character.cancelChargeTransition = Globals.CharacterAnimations.SHIELD
				if character.chargingProjectile:
					character.chargingProjectile.call_deferred("store_charged_projectile")
					
func process_neutral_special_inputs(_delta):
	if character.enableSpecialInput:
		if animationPlayer.is_playing():
			if Input.is_action_pressed(character.special):
				animationPlayer.stop(false)
		else:
			character.attackMultiplicator += 0.01
			if !Input.is_action_pressed(character.special):
				animationPlayer.play()
				character.enableSpecialInput = false
			
		
func on_hitlag_timeout():
	if character.currentAttack == Globals.CharacterAnimations.DOWNSPECIAL:
		create_rehit_timer(downSpecialRehitFrames)
	.on_hitlag_timeout()
