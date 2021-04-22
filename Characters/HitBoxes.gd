extends Node2D

onready var attackingObject = null
var attackingObjectState = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
var attackedObject = null
var attackDataEnum = null

var hitBoxesConnected = []
var hitBoxesConnectedCopy = []

var hitBoxesClashed = []

#connected if hitbox conneted with hurtbox, clashes if two hitboxes connected with each other
enum InteractionType {CONNECTED, CLASHED}

enum HitBoxType {SOUR, NEUTRAL, SWEET}

func _ready():
	attackingObject = get_parent().get_parent()
	if attackingObject.is_in_group("Character"):
		attackDataEnum = GlobalVariables.CharacterAnimations

func _process(delta):
	if !hitBoxesClashed.empty()||!hitBoxesConnected.empty():
		print("hitboxclashed " +str(hitBoxesClashed))
		print("hitboxconnected " +str(hitBoxesConnected))
	if !hitBoxesClashed.empty():
		process_connected_hitboxes(hitBoxesClashed, InteractionType.CLASHED)
		hitBoxesConnectedCopy = hitBoxesConnected.duplicate(true)
		hitBoxesClashed.clear()
		hitBoxesConnected.clear()
	elif !hitBoxesConnected.empty():
		if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
			process_connected_hitboxes(hitBoxesConnected, InteractionType.CONNECTED)
		hitBoxesConnected.clear()
		
func process_connected_hitboxes(hitBoxes, interactionType):
	disable_all_hitboxes()
	var highestHitboxPriority = 0
	var highestHitBox = null
	for hitbox in hitBoxes: 
		match hitbox:
			HitBoxType.SOUR:
				if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sour"]["priority"]
					highestHitBox = HitBoxType.SOUR
			HitBoxType.NEUTRAL:
				if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_neutral"]["priority"]
					highestHitBox = HitBoxType.NEUTRAL
			HitBoxType.SWEET:
				if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sweet"]["priority"]
					highestHitBox = HitBoxType.SWEET
	hitBoxes.clear()
	match interactionType:
		InteractionType.CONNECTED:
			apply_attack(highestHitBox, InteractionType.CONNECTED)
		InteractionType.CLASHED:
			apply_attack(highestHitBox, InteractionType.CLASHED)
	return highestHitBox

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			hitBoxShape.set_deferred('disabled',true)
		
func apply_attack(hbType, interactionType):
	var currentHitBoxNumber = attackingObject.currentHitBox
	var combinedAttackDataString = attackingObject.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_sweet"
	var currentAttackData = attackingObject.attackData[combinedAttackDataString]
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	#calculate damage if charged smash attack
	if attackingObject.is_in_group("Character"):
		attackDamage *= attackingObject.smashAttackMultiplier
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
	match interactionType:
		InteractionType.CONNECTED:
			apply_attack_connected(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier)
		InteractionType.CLASHED:
			apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier)

func apply_attack_connected(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier):
	calculate_hitlag_frames_connected(attackDamage, hitlagMultiplier)
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
			attackedObject.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile, attackingObject.global_position)
		elif attackedObject.perfectShieldActivated:
			attackedObject.is_attacked_handler_perfect_shield()
		else:
			attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	else:
		attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	
func apply_attack_clashed(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier):
	if attackedObject.is_in_group("Character"):
		var attackingObjectAttackType = GlobalVariables.match_attack_type(attackingObject.currentAttack)
		var attackedObjectAttackType = GlobalVariables.match_attack_type(attackedObject.currentAttack)
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
			var proccessConnectedHitboxesParamArray = [hitBoxesConnectedCopy, InteractionType.CONNECTED]
			var proccessConnectedHitboxesFunRef = funcref(self, "process_connected_hitboxes")
			HitBoxManager.add_colliding_hitbox(isAttackedHandlerFuncRef, isAttackedHandlerParamArray, attackingObject, attackDamage, hitlagMultiplier)
			
func calculate_hitlag_frames_clashed(attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)

func calculate_hitlag_frames_connected(attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagAttackedTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
		attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
	attackedObject.state.start_timer(attackedObject.state.hitlagAttackedTimer, attackedObjectHitlag)
#	print("calculated hitlag frames character "+ str(characterHitlag))
#	print("calculated hitlag frames attackedcharacter "+ str(attackedCharacterHitlag))

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
			
func check_hitbox_areas(area, hitboxType):
	attackingObjectState = attackingObject.currentState
	if area.is_in_group("Hitbox"): 
		if attackingObject != area.get_parent().attackingObject: 
			if hitBoxesClashed.empty():
				apply_hitlag(area, InteractionType.CLASHED)
			if !hitBoxesClashed.has(hitboxType):
				hitBoxesClashed.append(hitboxType)
#			print("hit Hitbox " +str(area.get_parent().attackingObject.name))
	elif area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject\
	&& hitBoxesClashed.empty():
		if hitBoxesConnected.empty():
			apply_hitlag(area, InteractionType.CONNECTED)
		if !hitBoxesConnected.has(hitboxType):
			hitBoxesConnected.append(hitboxType)
			
func apply_hitlag(hitArea, interactionType):
		match interactionType:
			InteractionType.CONNECTED:
				attackedObject = hitArea.get_parent().get_parent()
				if attackedObject.is_in_group("Character"):
					apply_hurtbox_character_character_hitlag()
			InteractionType.CLASHED:
				attackedObject = hitArea.get_parent().get_parent().get_parent()
				if attackedObject.is_in_group("Character"):
					apply_hitbox_character_character_hitlag()

func apply_hitbox_character_character_hitlag():
	attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
	attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)

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
				attackedObject.character_attacked_shield_handler(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			elif attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.character_attacked_handler(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.character_attacked_handler(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
