extends Node

var allConnectedHitboxes = []

var allConnectedHurtBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_connected_hitbox(attackingObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier):
	allConnectedHitboxes.append([attackingObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier])

func add_connected_hurtbox(attackingObject, attackedObject):
	allConnectedHurtBoxes.append([attackingObject, attackedObject])

func match_connected_hit_hurtboxes():
	var tempAllConnectedHurtBoxes = allConnectedHurtBoxes.duplicate(true)
	for hitObject in allConnectedHitboxes: 
		for hurtObject in tempAllConnectedHurtBoxes:
			if hurtObject[0] == hitObject[0]:
				apply_attack_connected(hitObject, hurtObject[1])
	allConnectedHitboxes.clear()
	allConnectedHurtBoxes.clear()

func _process(delta):
	if allConnectedHitboxes.size() >= 1\
	&& allConnectedHurtBoxes.size() >= 1:
		match_connected_hit_hurtboxes()

func apply_attack_connected(attackingObjectArray, attackedObject):
	var attackingObject = attackingObjectArray[0]
	var attackDamage = attackingObjectArray[1]
	var hitStun = attackingObjectArray[2]
	var launchAngle = attackingObjectArray[3]
	var launchVectorInversion = attackingObjectArray[4]
	var launchVelocity = attackingObjectArray[5]
	var weightLaunchVelocity = attackingObjectArray[6]
	var knockBackScaling = attackingObjectArray[7]
	var shieldStunMultiplier = attackingObjectArray[8]
	var shieldDamage = attackingObjectArray[9]
	var specialHitBoxEffects = attackingObjectArray[10]
	var hitlagMultiplier = attackingObjectArray[11]
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
			attackedObject.is_attacked_in_shield_calculations(attackDamage, shieldStunMultiplier, shieldDamage,  attackingObject.global_position)
		elif attackedObject.perfectShieldActivated:
			attackedObject.is_attacked_calculations_perfect_shield()
		else:
			attackedObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position)
	elif attackedObject.is_in_group("Projectile"):
		if !manage_hurtbox_special_interactions_projectile(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
			pass
	calculate_hitlag_frames_connected(attackingObject, attackedObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity)
	
func calculate_hitlag_frames_connected(attackingObject, attackedObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
#	attackingObjectHitlag = 200
#	attackedObjectHitlag = 200
	GlobalVariables.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
#	print("attackingObjectHitlag " +str(attackingObjectHitlag))
#	print("attackedObjectHitlag " +str(attackedObjectHitlag))
	if launchVelocity == 0 && weightLaunchVelocity == 0:
		attackedObject.is_attacked_handler_no_knockback(attackedObjectHitlag, attackingObject)
	else:
		attackedObject.is_attacked_handler(attackedObjectHitlag, attackingObject)
#	elif attackedObject.is_in_group("Projectile"):
#		attackedObject.state.create_hitlagAttacked_timer(attackedObjectHitlag)


func manage_hurtbox_special_interactions_projectile(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
	if attackedObject.is_in_group("Projectile"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var attackedObjectInteracted = attackedObject.apply_special_hitbox_effect_attacked(specialHitBoxEffects, attackingObject, attackDamage, interactionTypeToUse)
		if attackedObjectInteracted:
			return true
	return false
