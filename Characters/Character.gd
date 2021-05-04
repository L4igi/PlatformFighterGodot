extends KinematicBody2D

class_name Character

var characterName = null
#base stats to return to after changes were made
var baseDisableInputInfluence = 1200
var baseWalkMaxSpeed = 300
var baseRunMaxSpeed = 600
var baseStopForce = 1500
var baseJumpSpeed = 850
var baseAirSpeed = 600
export var damagePercent = 0.0
#walkforce is only used when no input is detected to slow the character down
var disableInputInfluence = 1200
var walkMaxSpeed = 300
var runMaxSpeed = 600
var airMaxSpeed = 500
var airStopForce = 450
var baseFallSpeed = 700
var maxFallSpeed = 850
var maxFallSpeedFastFall = 1200
var groundStopForce = 1500
var jumpSpeed = 900
var shortHopSpeed = 600
var fallingSpeed = 1.0
var currentMaxSpeed = baseWalkMaxSpeed
var pushingAction = false
var droppedPlatform = false
var walkThreashold = 0.35
#jump
var jumpCount = 0
var availabelJumps = 10
var airTime = 0
#platform
var platformCollision = null
var atPlatformEdge = null
#edge
var snappedEdge = null
var disableInput = false
var edgeGrabShape
var disabledEdgeGrab = false
var onEdge = false
var canGetEdgeInvincibility = true
var stageSlideCollider = null
#attack 
var smashAttack = null
var currentAttack = null
var jabCount = 0
var jabCombo = 1
var dashAttackSpeed = 1000
var chargingSmashAttack = false
var bufferedSmashAttack
var currentHitBox = 1
#movement
var currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
var pushingCharacter = null
var disableInputDI = false
var currentPushSpeed = 0
var velocity = Vector2.ZERO
var onSolidGround = null
var resetMovementSpeed = false
var shortTurnAround = false
var bufferXInput = 0
#crouch 
var crouchMovement = false
#bufferInput
var bufferInputWindow = 10
#hitstun 
var attackedCalculatedVelocity = 0
var initLaunchVelocity = Vector2.ZERO
var launchSpeedDecay = 0.025
var shortHitStun = false
var groundHitStun = 3.0
var getupRollDistance = 100
var tumblingThreashold = 600
var characterBouncing = false
var lastVelocity = Vector2.ZERO
var bounceThreashold = 600
var bounceReduction = 0.8
var stageBounceCollider = null
#tech 
var techRollDistance = 100
#shield
onready var characterShield = get_node("Shield")
var rollDistance = 150
var rolling = false
var shieldDropFrames = 11
var shieldStunFrames = 0
var maxSheildPushBack = 500
var shieldBreakFrames = 500
var shieldBreakVelocity = Vector2(0,-1000)
var enableShieldBreakGroundCheck = false
var perfectShieldFrames = 5
var perfectShieldFramesLeft = 5
var perfectShieldActivated = false
var shieldDropped = false
#grab
var grabbedCharacter = null
var inGrabByCharacter = null
var grabTime = 60
onready var interactionPoint = get_node("InteractionPoint")
#character stats
var weight = 1
var fastFallGravity = 4000
onready var gravity = 2000
onready var baseGravity = gravity
#hitlag 
var backUpHitStunTime = 0
var backUpDisableInputDI = false
var backUpDisableInput = false
var backupStopAnimation = false
var hitlagDI = Vector2.ZERO
var hitLagFrames = 3.0
#invincibility lengths
var rollInvincibilityFrames = 25
var spotdodgeInvincibilityFrames = 25
var rollGetupInvincibilityFrames = 20
var normalGetupInvincibilityFrames = 10
var attackGetupInvincibilityFrames = 15
var jumpGetupInvincibilityFrames = 15

var tween 

#signal for character state change
signal character_state_changed(state)

var currentState = GlobalVariables.CharacterState.GROUND

var collisionAreaShape
var characterSprite
var animationPlayer
var hurtBox

var attackData = null
var attackDataEnum = null
var state = null

#inputs
var up = ""
var down = ""
var left = ""
var right = ""
var jump = ""
var attack = ""
var shield = ""
var grab = ""
var special = ""

var state_factory 
onready var animatedSprite = get_node("AnimatedSprite")
var applySideStepFrames = true
var bufferedInputSmashAttack = false
var edgeRegrabTimer = null
var getUpType = null
var rollType = null
var characterTargetGetUpPosition = null
var grabFrames = 60.0
var hitLagTimer
var bufferHitLagFrames = 0
#var bufferFTiltWalk = false
var stopAreaEntered = false
var applyLandingLag = null
var queueFreeFall = false
var bufferMoveAirTransition = false
#last bounce collision platform 
var lastBounceCollision = null
#airdodge
var directionalAirDodgeInvicibilitFrames = 30.0
var neutralAirDodgeInvicibilitFrames = 30.0
var currentAirDodgeType = null
var airDodgeVelocity = 800
#drop platform timer 
var platformCollisionDisabledTimer = null
var platformCollisionDisableFrames = 30.0
#stopAreaVelocity
var stopAreaVelocity = Vector2.ZERO
#airdodge
var airdodgeAvailable = true
#jab combo
var comboNextJab = false
#shorthopAttack 
var shortHopAttack = false
#state already changed 
var stateChangedThisFrame = false
#turn around smash 
var turnAroundSmashAttack = false
#smashAttackMultiplier
var smashAttackMultiplier = 1.0
#buffered animation 
var bufferedAnimation = null
#rebound 
var bufferReboundFrames = 0.0
#superarmour 
var superArmourOn = false
var damagePercentArmour = 0.0
var knockbackArmour = 0.0
var multiHitArmour = 0
var hitsTaken = 0
#dictionary to keep moves that transition from attackair to attackground and vice versa in check
#dictionary to keep moves that transition from specialair to specialground and vice versa in check
#value of dictionary checks if move continous on ground(1) or applies landing lag while finishing animation(0)
var moveAirGroundTransition = {}
var moveGroundAirTransition = {}
var groundAirMoveTransition = false
var airGroundMoveTransition = false
var moveTransitionBufferedInput = null
#buffer Invincibilty frames to next state 
var bufferInvincibilityFrames = 0
#upspecial 
var upSpecialSpeed = Vector2(0,1200)
var upSpecialAnimationStep = 0
var downSpecialAnimationStep = 0
var sideSpecialAnimationStep = 0
var neutralSpecialAnimationStep = 0
var enableSpecialInput = false
#rehit 
var attackRehit = true
#reversed inputs 
var reversedInputs = false
#character controls 
var characterControls = null
var reverseTimer = null
var reverseFrames = 25.0
#counter 
var counterInvincibilityFrames = 15.0
var bufferedCounterDamage = 0.0
var counterDamageMultiplier = 1.2
var counteredHitlagFrames = 50.0
#landinglag
var normalLandingLag = 3.0
#items 
var grabbedItem = null
#backuped disabled hitboxes
var backupDisabledHitboxes = []
#if multiple character attacks connected but cannot clash 
var multiObjectsConnected = false

func _ready():
	self.set_collision_mask_bit(0,false)
	self.set_collision_mask_bit(2,true)
	animatedSprite.set_position(Vector2(0,0))
	#self.set_collision_mask_bit(1,false)
	var file = File.new()
	file.open("res://Characters/Mario/marioAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
	#assign nodes easy vars
	edgeGrabShape = $CharacterEdgeGrabArea/CharacterEdgeGrabShape
	collisionAreaShape = $InteractionAreas/CollisionArea/CollisionArea
	characterSprite = $AnimatedSprite
	animationPlayer = $AnimatedSprite/AnimationPlayer
	hurtBox = $InteractionAreas/Hurtbox
	tween = $Tween
	edgeRegrabTimer = GlobalVariables.create_timer("on_edgeRegrab_timeout", "EdgeRegrabTimer", self)
	platformCollisionDisabledTimer = GlobalVariables.create_timer("on_platformCollisionDisabled_timeout", "PlatformCollisionDisabledTimer", self)
	reverseTimer = GlobalVariables.create_timer("on_reverse_timeout", "ReverseTimer", self)
	animationPlayer.set_animation_process_mode(0)
	attackDataEnum = GlobalVariables.CharacterAnimations
	GlobalVariables.charactersInGame.append(self)
		
func set_attack_data_file():
	var file = File.new()
	file.open("res://Characters/debugAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
		
func _physics_process(delta):
	stateChangedThisFrame = false
	
func calc_hitstun_velocity(delta):
	if velocity.x < 0: 
		if(velocity.x - initLaunchVelocity.x *launchSpeedDecay) <= 0:
			velocity.x -= (initLaunchVelocity.x *launchSpeedDecay)
		else: 
			velocity.x = 0
	elif velocity.x > 0: 
		if(velocity.x - initLaunchVelocity.x *launchSpeedDecay) >= 0:
			velocity.x -= (initLaunchVelocity.x *launchSpeedDecay)
		else: 
			velocity.x = 0
	else: 
		velocity.x = 0
	
func snap_edge(collidingEdge):
	if edgeRegrabTimer.get_time_left():
		return
	disableInput = true
	onEdge = true
	velocity = Vector2.ZERO
	jumpCount = 1
	snappedEdge = collidingEdge
	if currentMoveDirection == GlobalVariables.MoveDirection.RIGHT && collidingEdge.edgeSnapDirection == "right": 
		currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		mirror_areas()
	elif currentMoveDirection == GlobalVariables.MoveDirection.LEFT && collidingEdge.edgeSnapDirection == "left": 
		currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		mirror_areas()
	var targetPosition = collidingEdge.global_position + Vector2((characterSprite.frames.get_frame("idle",0).get_size()/2).x,(characterSprite.frames.get_frame("idle",0).get_size()/4).y)
	if self.global_position < collidingEdge.centerStage.global_position:
		targetPosition = collidingEdge.global_position + Vector2(-(characterSprite.frames.get_frame("idle",0).get_size()/2).x,(characterSprite.frames.get_frame("idle",0).get_size()/4).y)
	state.play_animation("edgeSnap")
	$Tween.interpolate_property(self, "global_position", global_position, targetPosition , animationPlayer.get_current_animation_length(), Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	#calculate edge Invincibility time
	change_state(GlobalVariables.CharacterState.EDGE)
		

func get_character_size():
	return characterSprite.frames.get_frame("idle",0).get_size()
	
func disable_invincibility_edge_action():
	state.invincibilityTimer.stop_timer()
	enable_disable_hurtboxes(true)
			
func roll_calculator(distance): 
	if currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
		distance = abs(distance) 
		velocity.x = distance
	else:
		distance = abs(distance)* -1
		velocity.x = distance
		
func roll_calculator_tech(distance): 
	if state.get_input_direction_x() >= 0:
		distance = abs(distance) 
		velocity.x = distance
	else:
		distance = abs(distance)* -1
		velocity.x = distance
		
func finish_attack_animation(step):
	if state.inLandingLag: 
		return
	match step:
		0:
			disabledEdgeGrab = false
			if state.enable_player_input():
				match currentState:
					GlobalVariables.CharacterState.ATTACKGROUND:
						applySideStepFrames = true
						smashAttack = null
						applyLandingLag = null
						if !state.check_character_crouch():
							change_state(GlobalVariables.CharacterState.GROUND)
						disableInput = false
					GlobalVariables.CharacterState.ATTACKAIR:
						change_state(GlobalVariables.CharacterState.AIR)
						smashAttack = null

#overwrite in character to make special moves change to different states afterwards
func finish_special_animation(step):
	if state.enable_player_input():
		if onSolidGround:
			applySideStepFrames = true
			smashAttack = null
			if !state.check_character_crouch():
				change_state(GlobalVariables.CharacterState.GROUND)
			disableInput = false
		else:
			disableInput = false
			change_state(GlobalVariables.CharacterState.AIR)
			smashAttack = null
		
func apply_attack_animation_steps(step = 0):
	pass
	
func apply_special_animation_steps(step = 0):
	pass
	
func apply_item_throw_animation_step(step = 0):
	match step:
		0:
			grabbedItem.on_projectile_throw(currentAttack)
			grabbedItem = null
		1: 
			pass
	
func jab_animation_step(step = 0):
	match step: 
		0: 
			comboNextJab = true
		1:
			comboNextJab = false
	
func is_attacked_calculations(damage, hitStun,launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObjectGlobalPosition):
	lastBounceCollision = null
	hitsTaken += 1
	damagePercent += damage
	if weightLaunchVelocity == 0:
		if state.hitlagAttackedTimer.get_time_left():
			attackedCalculatedVelocity += calculate_attack_knockback(damage, launchVelocity, knockBackScaling)
		else:
			attackedCalculatedVelocity = calculate_attack_knockback(damage, launchVelocity, knockBackScaling)
	else:
		if state.hitlagAttackedTimer.get_time_left():
			attackedCalculatedVelocity += calculate_attack_knockback_weight_based(damage, weightLaunchVelocity, knockBackScaling)
		else:
			attackedCalculatedVelocity = calculate_attack_knockback_weight_based(damage, weightLaunchVelocity, knockBackScaling)
	#check superaromour 
	if superarmour_handler(damage):
		return 
	velocity = Vector2.ZERO
	if attackedCalculatedVelocity == 0: 
		initLaunchVelocity = Vector2.ZERO
	else:
		var launchVector = calculate_launch_vector(launchAngle, attackedCalculatedVelocity)
		if launchVectorInversion:
			launchVector.x = launchVector.x*-1
		initLaunchVelocity = launchVector
	if attackedCalculatedVelocity > tumblingThreashold || currentState == GlobalVariables.CharacterState.INGRAB:
	#todo: calculate if in tumble animation
		shortHitStun = false
	else: 
		shortHitStun = true
	backUpHitStunTime = hitStun
	if characterShield.shieldBreak:
		characterShield.shieldBreak_end()
		
func calculate_launch_vector(launchAngle, knockBack):
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
#	print("type of json angle " +str(launchAngle))
	match launchAngle: 
		deg2rad(0.0): 
			pass
#			print("Zero angle")
		deg2rad(361.0):
			var scaling = 0.25*PI*clamp(knockBack / 1500, 0.0, 1.0)
			launchVector = Vector2(cos(2*PI-scaling), sin(2*PI-scaling))
#			print("sakurai angle "+ str(launchVector))
#			print("sakurai angle scaling "+str(scaling))
		_:
			pass
#			print("Normal angle nothing to see here " +str(launchAngle))
	return launchVector
		
func is_attacked_calculations_perfect_shield():
	#todo: add perfect shield animation and particle effects
	print("perfect shield")
	
func is_attacked_in_shield_calculations(damage, shieldStunMultiplier, shieldDamage, attackingObjectGlobalPosition):
	shieldStunFrames = int(floor(damage * 0.8 * shieldStunMultiplier + 2))
	characterShield.buffer_shield_damage(damage, shieldDamage)
#	characterShield.apply_shield_damage(damage, shieldDamage)
	#todo: calculate shield hit pushback
	var pushBack = 0
	velocity = Vector2.ZERO
	var pushDirection = 1
	if attackingObjectGlobalPosition.x <= self.global_position.x:
		pushDirection = 1
	elif attackingObjectGlobalPosition.x >= self.global_position.x:
		pushDirection = -1
	initLaunchVelocity = pushDirection * Vector2(400, 0)
	bufferHitLagFrames = hitLagFrames
	#((damage * parameters.shield.mult * projectileMult * perfectshieldMult * groundedMult * aerialMult) + parameters.shield.constant) * 0.09 * perfectshieldMult2;
	
func calculate_attack_knockback(attackDamage, attackBaseKnockBack, knockBackScaling):
#	print("CALCULATING")
	var calculatedKnockBack = (((((damagePercent/2+(damagePercent*attackDamage)/4)*200/(weight*100/2+100)*1.4)+18)*knockBackScaling)+(attackBaseKnockBack))*1
#	var calculatedKnockBack = attackBaseKnockBack*7+((damagePercent/2+(damagePercent*attackDamage)/4)*5*knockBackScaling)*(2/weight)
#	print("calculatedKnockBack " +str(calculatedKnockBack))
	return calculatedKnockBack * 5
	
func calculate_attack_knockback_weight_based(attackDamage, attackBaseKnockBack, knockBackScaling):
	knockBackScaling = 1
	var calculatedKnockBack = attackBaseKnockBack*7+((1/2+(1*attackDamage)/4)*5*knockBackScaling)*(2/weight)
#	var calculatedKnockBack = (((((attackDamage/2+(attackDamage*attackDamage)/4)*200/(1*100/2+100)*1.4)+18)*knockBackScaling)+(attackBaseKnockBack))*1
#	print("calculatedKnockBackWeightBased " +str(calculatedKnockBack))
	return calculatedKnockBack
	
func apply_throw(actionType):
	var currentAttackData = (inGrabByCharacter.attackData[GlobalVariables.CharacterAnimations.keys()[actionType]])
	var attackDamage = currentAttackData["damage"]
	if actionType == GlobalVariables.CharacterAnimations.GRABJAB:
		return
	var hitStun = currentAttackData["hitStun"]
	var launchAngle = deg2rad(currentAttackData["launchAngle"])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var launchVectorX = launchVector.x
	var knockBackScaling = currentAttackData["knockBackGrowth"]/100
	#inverse x launch diretion depending on character position
	if global_position.x < inGrabByCharacter.global_position.x:
		launchVectorX *= -1
#	else:
#		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity"]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight"]
	self.global_position = inGrabByCharacter.global_position
	var isProjectile = false
	inGrabByCharacter = null
	bufferHitLagFrames = hitLagFrames
	print("buffered hitlag frames throw " +str(bufferHitLagFrames))
	var launchVectorInversion = false
	change_state(GlobalVariables.CharacterState.HITSTUNAIR)
	is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  inGrabByCharacter)
#	if shortHitStun:
#		state.play_animation("hurt_short")
#	elif !shortHitStun:
#		state.play_animation("hurt")
#	state.create_hitlagAttacked_timer(hitLagFrames)
#	inGrabByCharacter = null

func apply_smash_attack_steps(step = 0):
	match step:
		0:
			disableInputDI = false
			chargingSmashAttack = true
		1:
			if chargingSmashAttack:
				animationPlayer.stop(false)
		2:
			animationPlayer.play()

func apply_hurt_animation_step(step =0):
	match step: 
		0:
			disableInputDI = false
		1:
			#if !onSolidGround:
			if currentState == GlobalVariables.CharacterState.HITSTUNAIR:
				animationPlayer.stop(false)
			#else:
				#print(onSolidGround.name)
				
func shieldbreak_animation_step(step = 0):
	match step: 
		0: 
			enableShieldBreakGroundCheck = true
		1:
			state.play_animation("shieldBreakAirLoop")
		2:
			characterSprite.set_rotation_degrees(0.0)
			state.play_animation("shieldBreakLanding")
		3:
			state.play_animation("shieldBreakGroundLoop")
			
func dodge_animation_step(step = 0):
	match step: 
		0:
			match animationPlayer.get_current_animation():
				"roll":
					roll_calculator(rollDistance)
			disableInput = true
		1:
			state.create_invincibility_timer(rollInvincibilityFrames)
		2:
			if onSolidGround && Input.is_action_pressed(shield):
				change_state(GlobalVariables.CharacterState.SHIELD)
			elif state.enable_player_input():
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)
			
func getup_animation_step(step = 0):
	match step: 
		0:
			disableInput = true
			match animationPlayer.get_current_animation():
				"roll_getup":
					state.create_invincibility_timer(rollGetupInvincibilityFrames)
				"normal_getup":
					state.create_invincibility_timer(normalGetupInvincibilityFrames)
				"attack_getup":
					state.create_invincibility_timer(attackGetupInvincibilityFrames)
				"jump_getup":
					state.create_invincibility_timer(jumpGetupInvincibilityFrames)
		1:
			if state.enable_player_input():
				applySideStepFrames = true
				velocity = Vector2.ZERO
				change_state(GlobalVariables.CharacterState.GROUND)

func jump_getup_animation_step(step = 0):
	match step:
		0:
			if state.enable_player_input():
				queueFreeFall = true
				match currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						velocity = Vector2(-150, -1000)
					GlobalVariables.MoveDirection.RIGHT:
						velocity = Vector2(150, -1000)
				change_state(GlobalVariables.CharacterState.AIR)
			else:
				match currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						velocity = Vector2(-150, -1000)
					GlobalVariables.MoveDirection.RIGHT:
						velocity = Vector2(150, -1000)
				queueFreeFall = true

			
func apply_grab_animation_step(step = 0):
	match step: 
		0:
			grabbedCharacter = null
		1:
			if grabbedCharacter == null: 
				disableInput = false
				if Input.is_action_pressed(shield):
					change_state(GlobalVariables.CharacterState.SHIELD)
				else:
					change_state(GlobalVariables.CharacterState.GROUND)
			else: 
				velocity.x = 0
				state.create_grab_timer(grabFrames)
				
func disable_input_animation_step(step = 0):
	match step: 
		0:
			disableInput = true
		1:
			disableInput = false
			#apply grabjab to grabbed enemy
			if currentState == GlobalVariables.CharacterState.GRAB\
			&& currentAttack == GlobalVariables.CharacterAnimations.GRABJAB:
				state.gravity_on_off("on")
				grabbedCharacter.apply_throw(currentAttack)
			
func apply_throw_animation_step(step = 0):
	match step: 
		0:
			state.grabTimer.stop()
			disableInput = true
		1:
			state.gravity_on_off("on")
			grabbedCharacter.apply_throw(currentAttack)
			grabbedCharacter = null
			state.create_hitlag_timer(hitLagFrames)
		2: 
			disableInput = false
			change_state(GlobalVariables.CharacterState.GROUND)

func apply_tech_animation_step_ground(step = 0):
	match step: 
		0: 
			disableInput = true
		1:
			if onSolidGround && Input.is_action_pressed(shield):
				change_state(GlobalVariables.CharacterState.SHIELD)
			elif state.enable_player_input():
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)

func apply_tech_roll_animation_step_ground(step = 0):
	match step: 
		0: 
			disableInput = true
			match animationPlayer.get_current_animation():
				"techroll":
					roll_calculator_tech(techRollDistance)
		1:
			if onSolidGround && Input.is_action_pressed(shield):
				change_state(GlobalVariables.CharacterState.SHIELD)
			elif state.enable_player_input():
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)
				
func apply_tech_animation_step_air(step = 0):
	match step: 
		0: 
			disableInput = true
		1:
#			state.bufferedInput = GlobalVariables.CharacterAnimations.JUMP
			if state.enable_player_input():
				change_state(GlobalVariables.CharacterState.AIR)

func enable_disable_hurtboxes(enable = true):
	for singleHurtbox in hurtBox.get_children():
		if enable:
			singleHurtbox.set_deferred("disabled",false)
		else:
			singleHurtbox.set_deferred("disabled",true)

func other_character_state_changed():
	emit_signal("character_state_changed", self, currentState)

func set_current_hitbox(hitBoxNumber):
	currentHitBox = hitBoxNumber

func _on_AnimationPlayer_animation_finished(anim_name):
	if GlobalVariables.attackAnimationList.has(anim_name):
		finish_attack_animation(0)
	if GlobalVariables.specialAnimationList.has(anim_name):
		finish_special_animation(0)

func change_state(new_state, transitionBufferedInput = null):
	if currentState == new_state:
#		print(str(GlobalVariables.CharacterState.keys()[new_state]) +" Switching to current state again ")
		state.switch_to_current_state_again(transitionBufferedInput)
		return
	if stateChangedThisFrame:
		print(str(GlobalVariables.CharacterState.keys()[new_state]) +" State already changed this frame ")
		return
	stateChangedThisFrame = true
	moveTransitionBufferedInput = null
	var changeToState = new_state
	enable_disable_hurtboxes(true)
#	check_character_tilt_walk(new_state)
	if state != null:
		state.stateDone = true
		changeToState = check_state_transition(changeToState)
		bufferedAnimation = state.bufferedAnimation
		state.queue_free()
#		if state.is_queued_for_deletion():
#			print(str(state.name) +" STATE CAN BE QUEUED FREE AFTER FRAME")
#		else:
#			print(str(state.name) +"STATE CANNOT BE QUEUED FREE AFTER FRAME")
#	print(self.name + " Changing to " +str(GlobalVariables.CharacterState.keys()[changeToState]) + " transitionBufferedInput " +str(transitionBufferedInput))
#	if changeToState == GlobalVariables.CharacterState.AIR:
#		pass
	state = state_factory.get_state(changeToState).new()
	state.name = GlobalVariables.CharacterState.keys()[new_state]
#	if state.get_parent():
#		print("currentstate " +str(currentState) + " new state " +str(new_state))
#		print("state " +str(GlobalVariables.CharacterState.keys()[changeToState]) + " already has parent " +str(state.get_parent()))
	state.setup(funcref(self, "change_state"),transitionBufferedInput, animationPlayer, self)
	currentState = changeToState
	emit_signal("character_state_changed", self, currentState)
	add_child(state)
	
func check_state_transition(changeToState):
	if bufferMoveAirTransition && !shortHopAttack && !pushingCharacter:
		bufferMoveAirTransition = false
		match currentState:
			GlobalVariables.CharacterState.ATTACKGROUND:
				changeToState = GlobalVariables.CharacterState.ATTACKAIR
			GlobalVariables.CharacterState.SHIELD:
				if changeToState == GlobalVariables.CharacterState.AIR:
					if airdodgeAvailable:
						changeToState = GlobalVariables.CharacterState.AIRDODGE
			GlobalVariables.CharacterState.GROUND:
				if state.shortHopTimer.get_time_left():
					queueFreeFall = false
					state.process_jump()
		return changeToState
	if changeToState == GlobalVariables.CharacterState.GROUND\
	|| changeToState == GlobalVariables.CharacterState.AIR:
		match currentState:
			GlobalVariables.CharacterState.ATTACKAIR:
				if moveAirGroundTransition.has(currentAttack):
					if moveAirGroundTransition.get(currentAttack): 
						airGroundMoveTransition = true
						moveTransitionBufferedInput = state.bufferedInput
						changeToState = GlobalVariables.CharacterState.ATTACKGROUND
						return changeToState
			GlobalVariables.CharacterState.ATTACKGROUND:
				if moveGroundAirTransition.has(currentAttack):
					if moveGroundAirTransition.get(currentAttack): 
						groundAirMoveTransition = true
						moveTransitionBufferedInput = state.bufferedInput
						changeToState = GlobalVariables.CharacterState.ATTACKAIR
						return changeToState
			GlobalVariables.CharacterState.SPECIALAIR:
				if moveAirGroundTransition.has(currentAttack):
					if moveAirGroundTransition.get(currentAttack): 
						airGroundMoveTransition = true
						moveTransitionBufferedInput = state.bufferedInput
						changeToState = GlobalVariables.CharacterState.SPECIALGROUND
						return changeToState
			GlobalVariables.CharacterState.SPECIALGROUND:
				if moveGroundAirTransition.has(currentAttack):
					if moveGroundAirTransition.get(currentAttack): 
						groundAirMoveTransition = true
						moveTransitionBufferedInput = state.bufferedInput
						changeToState = GlobalVariables.CharacterState.SPECIALAIR
						return changeToState
	bufferInvincibilityFrames = 0.0
	groundAirMoveTransition = false
	airGroundMoveTransition = false
	return changeToState

func create_edgeRegrab_timer(waitTime):
	disabledEdgeGrab = true
	edgeGrabShape.set_deferred("disabled", true)
	GlobalVariables.start_timer(edgeRegrabTimer, waitTime)

func on_edgeRegrab_timeout():
	disabledEdgeGrab = false
	if currentState == GlobalVariables.CharacterState.AIR && state.get_input_direction_y() < 0.5:
		edgeGrabShape.set_deferred("disabled", false)
		
func create_platformCollisionDisabled_timer(waitTime):
	GlobalVariables.start_timer(platformCollisionDisabledTimer, waitTime)
	
func on_platformCollisionDisabled_timeout():
	call_deferred("set_collision_mask_bit",1,true)

func toggle_all_hitboxes(onOff, toggleSpecial = false):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						#todo: maybe change this to handle special hitboxes differently
#						if !toggleSpecial && !hitbox.is_in_group("SpecialHitBox"):
						if backupDisabledHitboxes.has(hitbox):
							hitbox.set_deferred('disabled',false)
		"off":
			backupDisabledHitboxes.clear()
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						if !hitbox.is_disabled():
							backupDisabledHitboxes.append(hitbox)
						hitbox.set_deferred('disabled',true)
			
func reset_hitboxes():
	for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
		for hitbox in areaHitbox.get_children():
			if hitbox is CollisionShape2D:
				hitbox.set_scale(Vector2(1,1))
				hitbox.set_position(Vector2(0,0))

func on_grab_release():
	#todo grab release motion
	state.gravity_on_off("on")
	inGrabByCharacter = null
	match currentMoveDirection: 
		0: 
			velocity = Vector2(400,-400)
		1: 
			velocity = Vector2(-400,-400)
	change_state(GlobalVariables.CharacterState.AIR)

func calculate_hitlag_di():
	var verticalInfluence = 0.17
	var horizontalInfluence = 0.09
	var originalLaunchRadian = atan2(initLaunchVelocity.y, initLaunchVelocity.x)
	var influenceDirection = 1
#	if initLaunchVelocity.y >= 0:
#		influenceDirection = -1
	var newLaunchRadian = originalLaunchRadian + (verticalInfluence*influenceDirection) * hitlagDI.x
	velocity = Vector2(cos(newLaunchRadian), sin(newLaunchRadian)) * attackedCalculatedVelocity
	velocity -= velocity * (horizontalInfluence * hitlagDI.y)
		
#called whenever character is attacked
func is_attacked_handler(hitLagFrames, attackingObject):
	bufferHitLagFrames = hitLagFrames
	#handle superarmour 
	if superArmourOn:
		state.create_hitlag_timer(bufferHitLagFrames)
	elif currentState == GlobalVariables.CharacterState.SHIELD\
	|| currentState == GlobalVariables.CharacterState.SHIELDSTUN:
		change_state(GlobalVariables.CharacterState.SHIELDSTUN)
	elif !perfectShieldActivated:
		change_state(GlobalVariables.CharacterState.HITSTUNAIR)
	else:
		state.create_hitlagAttacked_timer(bufferHitLagFrames)
		
func is_attacked_handler_no_knockback(hitLagFrames, attackingObject):
	bufferHitLagFrames = hitLagFrames
	#current animation is not finished on hitlag timeout
	state.create_hitlag_timer(bufferHitLagFrames)
		
func superarmour_handler(damage):
	if damagePercentArmour > 0.0:
		damagePercentArmour -= damage
		if damagePercent > 0.0:
			superArmourOn = true
			return true
	elif knockbackArmour > attackedCalculatedVelocity:
		superArmourOn = true 
		return true
	elif multiHitArmour > hitsTaken:
		superArmourOn = true
		return true
	superArmourOn = false
	return false
		
	
func change_max_speed(xInput):
	if !state.inMovementLag:
		var useXInput = xInput
		if bufferXInput != 0: 
			useXInput = bufferXInput
			bufferXInput = 0
		resetMovementSpeed = true
		if abs(useXInput) > walkThreashold:
			currentMaxSpeed = baseRunMaxSpeed
			state.play_animation("run")
		elif abs(useXInput) == 0:
			currentMaxSpeed = baseWalkMaxSpeed
			state.play_animation("idle")
		else:
			currentMaxSpeed = baseWalkMaxSpeed
			state.play_animation("walk")

#this function has to be implemented for each character
#it determins if on special attack use character changes to specialground or specialair
func change_to_special_state():
	if Input.is_action_just_pressed(up):
		pass
	elif Input.is_action_just_pressed(down):
		pass
	elif Input.is_action_just_pressed(left):
		pass
	elif Input.is_action_just_pressed(right):
		pass

func check_special_animation_steps():
	pass

func set_hitboxes_active(active = 0):
	match active:
		0: 
			state.hitBoxesActive = true
		1:
			state.hitBoxesActive = false
					
func apply_special_hitbox_effect_attacked(effectArray, interactionObject, attackingDamage, interactionType):
#	print(self.name + " apply_special_hitbox_effect_attacking " +str(effectArray) + " " +str(attackedObject.name) + " dmg " +str(attackingDamage) + " interactiontype " +str(interactionType))
	var characterInteracted = false
	for effect in effectArray:
		match effect: 
			GlobalVariables.SpecialHitboxType.REVERSE:
				if handle_effect_reverse_attacked(interactionType, interactionObject, attackingDamage):
					characterInteracted = true
			GlobalVariables.SpecialHitboxType.REFLECT:
				pass
			GlobalVariables.SpecialHitboxType.ABSORB:
				pass
			GlobalVariables.SpecialHitboxType.COUNTER:
				pass
	return characterInteracted
				
func handle_effect_reverse_attacked(interactionType, interactionObject, attackingDamage):
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CLASHED:
			return false
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			print(GlobalVariables.CharacterState.keys()[currentState])
			if currentState != GlobalVariables.CharacterState.SHIELD\
			&& currentState != GlobalVariables.CharacterState.SHIELDSTUN\
			&& !perfectShieldActivated:
				reverse_inputs()
				create_reverse_timer(reverseFrames)
				velocity.x *= -1
				match currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
						mirror_areas()
					GlobalVariables.MoveDirection.RIGHT:
						currentMoveDirection = GlobalVariables.MoveDirection.LEFT
						mirror_areas()
				return true
	return false

func handle_effect_counter_attacked(interactionType, interactionObject, attackingDamage):
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CLASHED:
			toggle_all_hitboxes("off")
			bufferedCounterDamage = attackingDamage
			change_state(GlobalVariables.CharacterState.COUNTER)
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			pass

func reverse_inputs():
	if reverseTimer.get_time_left():
		return
	if left == characterControls.get("left")\
	&& right == characterControls.get("right"):
		left = characterControls.get("right")
		right = characterControls.get("left")
	else:
		right = characterControls.get("right")
		left = characterControls.get("left")

func create_reverse_timer(waitTime):
	GlobalVariables.start_timer(reverseTimer, waitTime)

func on_reverse_timeout():
	reverse_inputs()

func is_currentAttack_itemthrow():
	match currentAttack:
		GlobalVariables.CharacterAnimations.THROWITEMDOWN:
			return true
		GlobalVariables.CharacterAnimations.THROWITEMFORWARD:
			return true
		GlobalVariables.CharacterAnimations.THROWITEMUP:
			return true
	return false
	
func get_input_direction_x():
	return Input.get_action_strength(right) - Input.get_action_strength(left)
			
func get_input_direction_y():
	return Input.get_action_strength(down) - Input.get_action_strength(up)
	
func mirror_areas():
	match currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			set_scale(Vector2(-1*abs(get_scale().x), abs(get_scale().y)))
		GlobalVariables.MoveDirection.RIGHT:
			set_scale(Vector2(-1*abs(get_scale().x), -1*abs(get_scale().y)))

func attack_handler_air_throw_attack():
	if (abs(get_input_direction_x()) == 0) \
	&& get_input_direction_y() == 0:
		currentAttack = GlobalVariables.CharacterAnimations.THROWITEMFORWARD
		state.play_attack_animation("throw_item_forward")
	elif get_input_direction_y() < 0:
		currentAttack = GlobalVariables.CharacterAnimations.THROWITEMUP
		state.play_attack_animation("throw_item_up")
	elif get_input_direction_y() > 0:
		currentAttack = GlobalVariables.CharacterAnimations.THROWITEMDOWN
		state.play_attack_animation("throw_item_down")
	elif get_input_direction_x() > 0:
		if currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
			currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
			mirror_areas()
		currentAttack = GlobalVariables.CharacterAnimations.THROWITEMFORWARD
		state.play_attack_animation("throw_item_forward")
	elif get_input_direction_x() < 0:
		if currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
			currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			mirror_areas()
		currentAttack = GlobalVariables.CharacterAnimations.THROWITEMFORWARD
		state.play_attack_animation("throw_item_forward")

#checks if current attack/state can catch item, pick up item
func check_item_catch_attack():
	if grabbedItem: 
		return false
	match currentState:
		GlobalVariables.CharacterState.ATTACKAIR:
			return true
		GlobalVariables.CharacterState.ATTACKGROUND:
			match currentAttack:
				GlobalVariables.CharacterAnimations.FSMASH: 
					return false
				GlobalVariables.CharacterAnimations.DSMASH:
					return false
				GlobalVariables.CharacterAnimations.UPSMASH:
					return false
			return true
	return false
