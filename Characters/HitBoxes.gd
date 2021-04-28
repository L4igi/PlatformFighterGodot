extends Node2D

onready var attackingObject = null
var attackingObjectState = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
onready var specialSpot = $HitBoxSpecial/Special
var attackedObject = null

var hitBoxesConnected = []
var hitBoxesConnectedCopy = []

var hitBoxesClashed = []

enum HitBoxType {SOUR, NEUTRAL, SWEET, SPECIAL}

func _ready():
	attackingObject = get_parent().get_parent()

func _process(delta):
	if !hitBoxesClashed.empty():
		process_connected_hitboxes(hitBoxesClashed, GlobalVariables.HitBoxInteractionType.CLASHED)
		hitBoxesClashed.clear()
		hitBoxesConnected.clear()
	else:
		if !hitBoxesConnected.empty():
			if attackedObject.is_in_group("Character"):
				if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
					process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED)
			elif attackedObject.is_in_group("Projectile"):
				process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED)
			hitBoxesConnected.clear()
		
func process_connected_hitboxes(hitBoxes, interactionType):
	disable_all_hitboxes()
	var highestHitBox = get_hightest_priority_hitbox(attackingObject, hitBoxes)
	hitBoxes.clear()
	hitBoxesConnectedCopy = hitBoxesConnected.duplicate(true)
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			apply_attack(highestHitBox, GlobalVariables.HitBoxInteractionType.CONNECTED)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack(highestHitBox, GlobalVariables.HitBoxInteractionType.CLASHED)
	return highestHitBox
	
func get_hightest_priority_hitbox(object, hitboxes):
	var highestHitboxPriority = 0
	var highestHitBox = null
	for hitbox in hitboxes: 
		match hitbox:
			HitBoxType.SOUR:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sour"]["priority"]
					highestHitBox = HitBoxType.SOUR
			HitBoxType.NEUTRAL:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_neutral"]["priority"]
					highestHitBox = HitBoxType.NEUTRAL
			HitBoxType.SWEET:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sweet"]["priority"]
					highestHitBox = HitBoxType.SWEET
			HitBoxType.SPECIAL:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_special"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_special"]["priority"]
					highestHitBox = HitBoxType.SPECIAL
	return highestHitBox

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			#exclude special hitbox from being disbaled if attack hits
			if !hitBoxShape.is_in_group("SpecialHitBox"):
				hitBoxShape.set_deferred('disabled',true)
	
func get_attackData_match_highest_hitbox_json_data(object, hbType):
	var combinedAttackDataString = object.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sweet"
		HitBoxType.SPECIAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_special"
	return object.attackData[combinedAttackDataString]
		
func apply_attack(hbType, interactionType):
	var currentHitBoxNumber = attackingObject.currentHitBox
	var currentAttackData = get_attackData_match_highest_hitbox_json_data(attackingObject, hbType)
	print("hbType " +str(hbType))
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	#calculate damage if charged smash attack
	if attackingObject.is_in_group("Character"):
		if attackingObject.currentAttack == GlobalVariables.CharacterAnimations.COUNTER:
			attackDamage = clamp(attackingObject.bufferedCounterDamage, attackDamage, 100)
		attackDamage *= attackingObject.smashAttackMultiplier
	attackDamage = stepify(attackDamage, 0.1)
	var hitStun = currentAttackData["hitStun_" + String(currentHitBoxNumber)]
	var launchAngle = deg2rad(currentAttackData["launchAngle_" + String(currentHitBoxNumber)])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_" + String(currentHitBoxNumber)]/100
	var launchVectorInversion = false
	var reboundingHitbox = currentAttackData["rebounding_" + String(currentHitBoxNumber)]
	var transcendentHitBox = currentAttackData["transcendent_" + String(currentHitBoxNumber)]
	##direction player if facing
	if currentAttackData["facing_direction"] == 0:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	elif currentAttackData["facing_direction"] == 1\
	&& attackedObject.global_position.x < attackingObject.global_position.x:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	#opposit direction player if facing
	if currentAttackData["facing_direction"] == 2:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = true
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = false
	#always send attacked attackingObject in the direction it is in comparison to attacker
	elif currentAttackData["facing_direction"] == 3:
		if attackedObject.global_position.x <= attackingObject.global_position.x:
			launchVectorInversion = true
		else:
			launchVectorInversion = false
	var launchVelocity = currentAttackData["launchVelocity_" + String(currentHitBoxNumber)]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight_" + String(currentHitBoxNumber)]
	var shieldStunMultiplier = currentAttackData["shieldStun_multiplier_" + String(currentHitBoxNumber)]
	var shieldDamage = currentAttackData["shield_damage_" + String(currentHitBoxNumber)]
	#todo check if is projectile
	var isProjectile = false
	var hitlagMultiplier = currentAttackData["hitlag_multiplier_" + String(currentHitBoxNumber)]
	var specialHitBoxEffects = []
	for effect in currentAttackData.get("effects_" +String(currentHitBoxNumber)).values():
		specialHitBoxEffects.append(GlobalVariables.SpecialHitboxType.keys().find(effect))
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			apply_attack_connected(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, specialHitBoxEffects)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)

func apply_attack_connected(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, specialHitBoxEffects):
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
			attackedObject.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile, attackingObject.global_position)
		elif attackedObject.perfectShieldActivated:
			attackedObject.is_attacked_handler_perfect_shield()
		else:
			attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	else:
		attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	var attackedObjectInteracted = attackedObject.apply_special_hitbox_effect_attacked(specialHitBoxEffects, attackingObject, attackDamage, GlobalVariables.HitBoxInteractionType.CONNECTED)
	calculate_hitlag_frames_connected(attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity)

func apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	if attackedObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_attack_clashed_character_character(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	elif (attackingObject.is_in_group("Projectile")\
	&& attackedObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Projectile")): 
		apply_attack_clashed_character_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	#projectile projectile interaction 
	elif attackedObject.is_in_group("Projectile")\
	&& attackingObject.is_in_group("Projectile"):
		apply_attack_clashed_projectile_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) 
			
			
func apply_attack_clashed_character_character(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
		var attackingObjectAttackType = GlobalVariables.match_attack_type_character(attackingObject.currentAttack)
		var attackedObjectAttackType = GlobalVariables.match_attack_type_character(attackedObject.currentAttack)
		#match interaction cases
		#check case if attack has Transcendent priority
		#both characters attacked in air: 
		if attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.AERIAL:
			calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier)
			attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
		#ground air || air ground collision
		if (attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED)\
		|| (attackedObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED):
			calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier)
			attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
		#ground ground collision check for higher priority (damage percent dealt)
		if attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED:
			#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
			var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
			var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_handler")
			HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_character_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	#if projectile belongs to attacker let it pass through 
#	if attackingObject.is_in_group("Projectile"):
#		if attackingObject.parentNode == attackedObject: 
#			return 
#	elif attackedObject.is_in_group("Projectile"):
#		if attackedObject.parentNode == attackingObject: 
#			return 
	#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_handler")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_projectile_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) :
	#if projectile belongs to attacker let it pass through 
#	if attackingObject.is_in_group("Projectile"):
#		if attackingObject.parentNode == attackedObject: 
#			return 
#	elif attackedObject.is_in_group("Projectile"):
#		if attackedObject.parentNode == attackingObject: 
#			return 
	#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_handler")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)

func calculate_hitlag_frames_connected(attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
#	attackingObjectHitlag = 200
#	attackedObjectHitlag = 200
	attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
	print("attackingObjectHitlag " +str(attackingObjectHitlag))
	print("attackedObjectHitlag " +str(attackedObjectHitlag))
	if attackedObject.is_in_group("Character"):
		if launchVelocity == 0 && weightLaunchVelocity == 0:
			attackedObject.character_attacked_handler_no_knockback(attackedObjectHitlag)
		else:
			attackedObject.character_attacked_handler(attackedObjectHitlag)
#	elif attackedObject.is_in_group("Projectile"):
#		attackedObject.state.create_hitlagAttacked_timer(attackedObjectHitlag)

func apply_grab():
	if attackingObject.currentMoveDirection == attackedObject.currentMoveDirection:
		if attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedObject.state.mirror_areas()
	attackedObject.inGrabByCharacter = attackingObject
	attackedObject.change_state(GlobalVariables.CharacterState.INGRAB)

func _on_HitBoxSweetArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SWEET)


func _on_HitBoxNeutralArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.NEUTRAL)


func _on_HitBoxSourArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SOUR)
	
func _on_HitBoxSpecial_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SPECIAL)
			
func check_hitbox_areas(area, hitboxType):
	attackingObjectState = attackingObject.currentState
	if area.is_in_group("Hitbox"): 
		if attackingObject != area.get_parent().get_parent().get_parent(): 
			attackedObject = area.get_parent().get_parent().get_parent()
			attackingObject.currentInteractionObject = attackedObject
#			if is_projectile_parentNode_interaction(attackedObject):
#				return
			if hitBoxesClashed.empty():
				apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CLASHED)
			if !hitBoxesClashed.has(hitboxType):
				hitBoxesClashed.append(hitboxType)
#			print("hit Hitbox " +str(area.get_parent().attackingObject.name))
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject:
		attackedObject = area.get_parent().get_parent()
		attackingObject.currentInteractionObject = attackedObject
		if is_projectile_parentNode_interaction(attackedObject):
			return
		if hitBoxesClashed.empty() && hitBoxesConnected.empty():
			apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CONNECTED)
		if !hitBoxesConnected.has(hitboxType):
			hitBoxesConnected.append(hitboxType)
			
func is_projectile_parentNode_interaction(object):
	if attackingObject.is_in_group("Projectile"):
		if attackingObject.check_hit_parentNode(object):
			return true
	return false
			
func apply_hitlag(hitArea, interactionType):
		match interactionType:
			GlobalVariables.HitBoxInteractionType.CONNECTED:
				attackedObject = hitArea.get_parent().get_parent()
				attackingObject.currentInteractionObject = attackedObject
				apply_hurtbox_hitlag()
			GlobalVariables.HitBoxInteractionType.CLASHED:
				attackedObject = hitArea.get_parent().get_parent().get_parent()
				attackingObject.currentInteractionObject = attackedObject
				apply_hurtbox_hitlag()

func apply_hitbox_hitlag(lagFrames):
	attackedObject.state.create_hitlag_timer(lagFrames)
	attackingObject.state.create_hitlag_timer(lagFrames)

func apply_hurtbox_hitlag():
	if attackedObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_hurtbox_character_character_hitlag()
	elif (attackingObject.is_in_group("Projectile")\
	&& attackedObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Projectile")): 
		apply_hurtbox_character_projectile_hitlag()

func apply_hurtbox_character_character_hitlag():
	if attackedObject != self.get_parent().get_parent():
		if attackingObject.currentState == GlobalVariables.CharacterState.GRAB:
			if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.AIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKAIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.GRAB\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALGROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALAIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ROLL\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELDBREAK\
			|| attackedObject.currentState == GlobalVariables.CharacterState.EDGEGETUP:
				attackingObject.grabbedCharacter = attackedObject
				attackingObject.apply_grab_animation_step(1)
				apply_grab()
		else:
			attackingObject.initLaunchVelocity = attackingObject.velocity
			if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			elif attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)

func apply_hurtbox_character_projectile_hitlag():
	if attackedObject != self.get_parent().get_parent():
		attackingObject.initLaunchVelocity = attackingObject.velocity
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
		if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
		&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
			attackedObject.perfectShieldActivated = true
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
		else:
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
	else:
		attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
		attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
		

func get_hitbox_by_area(area):
	var sweetSpotArea = sweetSpot.get_parent()
	var sourSpotArea = sourSpot.get_parent()
	var neutralSpotArea = neutralSpot.get_parent()
	var specialSpotArea = specialSpot.get_parent()
	match area:
		sweetSpotArea:
			return HitBoxType.SWEET
		sourSpotArea:
			return HitBoxType.SOUR
		neutralSpotArea:
			return HitBoxType.NEUTRAL
		specialSpotArea:
			return HitBoxType.SPECIAL
