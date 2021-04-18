extends Node2D

onready var character = get_parent().get_parent()
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
var attackedCharacter = null
var attackedCharacterState = null

var hitBoxesConnected = []

enum HitBoxType {SOUR, NEUTRAL, SWEET}

func _process(delta):
	if !hitBoxesConnected.empty():
		disable_all_hitboxes()
		if character.currentState != GlobalVariables.CharacterState.GRAB:
			var highestHitboxPriority = 0
			var highestHitBox = null
			for hitbox in hitBoxesConnected: 
				match hitbox:
					HitBoxType.SOUR:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sour"]["priority"]
							highestHitBox = HitBoxType.SOUR
					HitBoxType.NEUTRAL:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]["priority"]
							highestHitBox = HitBoxType.NEUTRAL
					HitBoxType.SWEET:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sweet"]["priority"]
							highestHitBox = HitBoxType.SWEET
			if character.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
			|| character.currentState == GlobalVariables.CharacterState.ATTACKAIR:
				apply_attack(highestHitBox)
		hitBoxesConnected.clear()

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			hitBoxShape.set_deferred('disabled',true)
		
func apply_attack(hbType):
#	print("applying attack")
	var currentHitBoxNumber = character.currentHitBox
	var combinedAttackDataString = character.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_sweet"
	var currentAttackData = character.attackData[combinedAttackDataString]
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	var hitStun = currentAttackData["hitStun_" + String(currentHitBoxNumber)]
	var launchAngle = deg2rad(currentAttackData["launchAngle_" + String(currentHitBoxNumber)])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_" + String(currentHitBoxNumber)]/100
	var launchVectorX = launchVector.x
	#inverse x launch diretion depending on character position
	if attackedCharacter.global_position.x < character.global_position.x:
		launchVectorX *= -1
	else:
		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity_" + String(currentHitBoxNumber)]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight_" + String(currentHitBoxNumber)]
	var shieldStunMultiplier = currentAttackData["shieldStun_multiplier_" + String(currentHitBoxNumber)]
	var shieldDamage = currentAttackData["shield_damage_" + String(currentHitBoxNumber)]
	var isProjectile = false
	if attackedCharacterState == GlobalVariables.CharacterState.SHIELD:
		attackedCharacter.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile, character)
	elif attackedCharacter.perfectShieldActivated:
		attackedCharacter.is_attacked_handler_perfect_shield()
	else:
		attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, character)


func apply_grab():
	if character.currentMoveDirection == attackedCharacter.currentMoveDirection:
		if attackedCharacter.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedCharacter.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedCharacter.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedCharacter.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedCharacter.state.mirror_areas()
	attackedCharacter.inGrabByCharacter = character
	attackedCharacter.change_state(GlobalVariables.CharacterState.INGRAB)

func _on_HitBoxSweetArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.SWEET):
			hitBoxesConnected.append(HitBoxType.SWEET)


func _on_HitBoxNeutralArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.NEUTRAL):
			hitBoxesConnected.append(HitBoxType.NEUTRAL)


func _on_HitBoxSourArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.SOUR):
			hitBoxesConnected.append(HitBoxType.SOUR)
			
func apply_hitlag(hitArea):
	attackedCharacter = hitArea.get_parent().get_parent()
	attackedCharacterState = attackedCharacter.currentState
	if attackedCharacter != self.get_parent().get_parent():
		if character.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
		|| character.currentState == GlobalVariables.CharacterState.ATTACKAIR:
			character.initLaunchVelocity = character.velocity
			attackedCharacter = hitArea.get_parent().get_parent()
			if attackedCharacterState == GlobalVariables.CharacterState.SHIELD:
				attackedCharacter.character_attacked_shield_handler(attackedCharacter.hitLagFrames)
				character.state.create_hitlag_timer(character.hitLagFrames)
			elif attackedCharacterState == GlobalVariables.CharacterState.GROUND\
			&& attackedCharacter.state.shieldDropTimer.get_time_left() && attackedCharacter.perfectShieldFramesLeft > 0:
				attackedCharacter.perfectShieldActivated = true
				attackedCharacter.character_attacked_handler(attackedCharacter.hitLagFrames + (8.0))
				character.state.create_hitlag_timer(character.hitLagFrames + (11.0))
			else:
				attackedCharacter.character_attacked_handler(attackedCharacter.hitLagFrames)
				character.state.create_hitlag_timer(character.hitLagFrames)
		#manage grab if character hit other character hitbox
		elif character.currentState == GlobalVariables.CharacterState.GRAB:
			if attackedCharacter.currentState == GlobalVariables.CharacterState.GROUND\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.AIR\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.ATTACKAIR\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.GRAB\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.SPECIALGROUND\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.SPECIALAIR\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.SHIELD\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.ROLL\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.SHIELDBREAK\
			|| attackedCharacter.currentState == GlobalVariables.CharacterState.EDGEGETUP:
				character.grabbedCharacter = attackedCharacter
				apply_grab()
				
