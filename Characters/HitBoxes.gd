extends Node2D

onready var attackingObject = null
var attackingObjectState = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
onready var specialSpot = $HitBoxSpecial/Special
var attackedObjectArray = []
var attackedObject = null
var highestHitBoxConnected = null

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
		attackedObjectArray.clear()
	else:
		if !hitBoxesConnected.empty():
			process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED)
			hitBoxesConnected.clear()
			attackedObjectArray.clear()
			hitBoxesClashed.clear()
	
func process_connected_hitboxes(hitBoxes, interactionType, calledAgain = false):
	if !calledAgain:
		attackingObject.toggle_all_hitboxes("off")
		highestHitBoxConnected = get_hightest_priority_hitbox(attackingObject, hitBoxes)
		hitBoxes.clear()
		hitBoxesConnectedCopy = hitBoxesConnected.duplicate(true)
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			for object in attackedObjectArray:
				if object.is_in_group("Character"):
					if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
						HitBoxHurtBoxManager.add_connected_hurtbox(attackingObject, object)
				elif object.is_in_group("Projectile"):
					HitBoxHurtBoxManager.add_connected_hurtbox(attackingObject, object)
			set_hitbox_data(highestHitBoxConnected, GlobalVariables.HitBoxInteractionType.CONNECTED)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			set_hitbox_data(highestHitBoxConnected, GlobalVariables.HitBoxInteractionType.CLASHED)
	
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
		
func set_hitbox_data(hbType, interactionType):
	var currentHitBoxNumber = attackingObject.currentHitBox
	var currentAttackData = get_attackData_match_highest_hitbox_json_data(attackingObject, hbType)
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
	var hitlagMultiplier = currentAttackData["hitlag_multiplier_" + String(currentHitBoxNumber)]
	var specialHitBoxEffects = []
	for effect in currentAttackData.get("effects_" +String(currentHitBoxNumber)).values():
		specialHitBoxEffects.append(GlobalVariables.SpecialHitboxType.keys().find(effect))
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			HitBoxHurtBoxManager.add_connected_hitbox(attackingObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)

func apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	if attackedObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_attack_clashed_character_character(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	elif (attackingObject.is_in_group("Projectile")\
	&& attackedObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Projectile")): 
		apply_attack_clashed_character_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	#projectile projectile interaction 
	elif attackedObject.is_in_group("Projectile")\
	&& attackingObject.is_in_group("Projectile"):
		apply_attack_clashed_projectile_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) 
			
			
func apply_attack_clashed_character_character(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
		var attackingObjectAttackType = GlobalVariables.match_attack_type_character(attackingObject.currentAttack)
		var attackedObjectAttackType = GlobalVariables.match_attack_type_character(attackedObject.currentAttack)
		#match interaction cases
		#check case if attack has Transcendent priority
		#both characters attacked in air: 
		if attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.AERIAL:
#			calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier)
#			attackedObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position)
			process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED, true)
		#ground air || air ground collision
		if (attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED)\
		|| (attackedObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED):
			calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier)
			attackedObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position)
		#ground ground collision check for higher priority (damage percent dealt)
		if attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED:
			#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
			var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
			var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
			HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_character_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_projectile_projectile(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) :
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		GlobalVariables.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)


func apply_grab():
	if attackingObject.currentMoveDirection == attackedObject.currentMoveDirection:
		if attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedObject.character.mirror_areas()
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
			if check_item_catch(attackingObject, attackedObject):
				return
			if hitBoxesClashed.empty():
				apply_hurtbox_hitlag(attackingObject, attackedObject, true)
				attackedObjectArray.append(attackedObject)
			elif !attackedObjectArray.has(attackedObject):
				attackedObjectArray.append(attackedObject)
				apply_hurtbox_hitlag(attackingObject, attackedObject)
			if !hitBoxesClashed.has(hitboxType):
				hitBoxesClashed.append(hitboxType)
#			print("hit Hitbox " +str(area.get_parent().attackingObject.name))
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject:
		attackedObject = area.get_parent().get_parent()
		if is_projectile_parentNode_interaction(attackingObject, attackedObject):
			return
		if hitBoxesClashed.empty() && hitBoxesConnected.empty():
			apply_hurtbox_hitlag(attackingObject, attackedObject, true)
			attackedObjectArray.append(attackedObject)
		elif !attackedObjectArray.has(attackedObject):
			attackedObjectArray.append(attackedObject)
			apply_hurtbox_hitlag(attackingObject, attackedObject)
		if !hitBoxesConnected.has(hitboxType):
			hitBoxesConnected.append(hitboxType)
	if area.is_in_group("HurtboxProjectile"):
		attackedObject = area.get_parent()
		if attackedObject != attackingObject\
		&& attackedObject.parentNode != attackingObject:
			if is_projectile_parentNode_interaction(attackingObject, attackedObject):
				return
			if hitBoxesClashed.empty() && hitBoxesConnected.empty():
				apply_hurtbox_hitlag(attackingObject, attackedObject, true)
				attackedObjectArray.append(attackedObject)
			elif !attackedObjectArray.has(attackedObject):
				attackedObjectArray.append(attackedObject)
				apply_hurtbox_hitlag(attackingObject, attackedObject)
			if !hitBoxesConnected.has(hitboxType):
				hitBoxesConnected.append(hitboxType)
			
			
func is_projectile_parentNode_interaction(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile"):
		if attackingObject.check_hit_parentNode(attackedObject):
			return attackingObject
	if attackedObject.is_in_group("Projectile"):
		if attackedObject.check_hit_parentNode(attackingObject):
			return attackedObject
	return null
	
func check_item_catch(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile")\
		&& attackedObject.is_in_group("Character"):
			if attackingObject.get_parent() != attackedObject:
				if attackedObject.check_item_catch_attack()\
				&& attackingObject.grabAble:
					attackingObject.on_projectile_catch(attackedObject)
					return true
			elif attackedObject.get_parent() == attackingObject: 
				return true
	elif attackedObject.is_in_group("Projectile")\
		&& attackingObject.is_in_group("Character"):
			if attackedObject.get_parent() != attackingObject:
				if attackingObject.check_item_catch_attack()\
				&& attackedObject.grabAble:
					attackedObject.on_projectile_catch(attackingObject)
					return true
			elif attackedObject.get_parent() == attackingObject: 
				return true
	return false

func apply_hitbox_hitlag(lagFrames):
	attackedObject.state.create_hitlag_timer(lagFrames)
	attackingObject.state.create_hitlag_timer(lagFrames)

func apply_hurtbox_hitlag(attacking, attacked, firstCall = false):
	if firstCall: 
		apply_hurtbox_hitlag_firstCall(attacking, attacked)
	else:
		if attacking.is_in_group("Character"):
			if attacking.currentState == GlobalVariables.CharacterState.GRAB:
				return 
			if attacked.currentState == GlobalVariables.CharacterState.SHIELD:
				attacked.state.create_hitlag_timer(attacked.hitLagFrames)
			elif attacked.currentState == GlobalVariables.CharacterState.GROUND\
			&& attacked.state.shieldDropTimer.get_time_left() && attacked.perfectShieldFramesLeft > 0:
				attacked.perfectShieldActivated = true
				attacked.state.create_hitlag_timer(attacked.hitLagFrames + (8.0))
				if attackingObject.state.hitlagTimer.get_time_left() < attackingObject.hitLagFrames + (11.0):
					attackingObject.state.hitlagTimer.set_wait_time(attackingObject.hitLagFrames + (11.0))
		else:
			attacked.state.create_hitlag_timer(attacked.hitLagFrames)

func apply_hurtbox_hitlag_firstCall(attacking, attacked):
	if attacking.is_in_group("Character")\
	&& attacked.is_in_group("Character")\
	&& attacking.currentState == GlobalVariables.CharacterState.GRAB:
		if attacked.currentState == GlobalVariables.CharacterState.GROUND\
		|| attacked.currentState == GlobalVariables.CharacterState.AIR\
		|| attacked.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
		|| attacked.currentState == GlobalVariables.CharacterState.ATTACKAIR\
		|| attacked.currentState == GlobalVariables.CharacterState.GRAB\
		|| attacked.currentState == GlobalVariables.CharacterState.SPECIALGROUND\
		|| attacked.currentState == GlobalVariables.CharacterState.SPECIALAIR\
		|| attacked.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attacked.currentState == GlobalVariables.CharacterState.ROLL\
		|| attacked.currentState == GlobalVariables.CharacterState.SHIELDBREAK\
		|| attacked.currentState == GlobalVariables.CharacterState.EDGEGETUP:
			attacking.grabbedCharacter = attacked
			attacking.apply_grab_animation_step(1)
			apply_grab()
	else:
		attacking.initLaunchVelocity = attacking.velocity
		if attacked.is_in_group("Character"):
			if attacked.currentState == GlobalVariables.CharacterState.SHIELD:
				attacked.state.create_hitlag_timer(attacked.hitLagFrames)
				attacking.state.create_hitlag_timer(attacking.hitLagFrames)
			if attacked.currentState == GlobalVariables.CharacterState.GROUND\
			&& attacked.state.shieldDropTimer.get_time_left() && attacked.perfectShieldFramesLeft > 0:
				attacked.perfectShieldActivated = true
				attacked.state.create_hitlag_timer(attacked.hitLagFrames + (8.0))
				attacking.state.create_hitlag_timer(attacking.hitLagFrames + (11.0))
			else:
				attacked.state.create_hitlag_timer(attacked.hitLagFrames)
				attacking.state.create_hitlag_timer(attacking.hitLagFrames)
		else:
			attacked.state.create_hitlag_timer(attacked.hitLagFrames)
			attacking.state.create_hitlag_timer(attacking.hitLagFrames)

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
