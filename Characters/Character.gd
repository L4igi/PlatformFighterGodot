extends KinematicBody2D

class_name Character
#base stats to return to after changes were made
var baseDisableInputInfluence = 1200
var baseWalkMaxSpeed = 300
var baseRunMaxSpeed = 600
var baseStopForce = 1500
var baseJumpSpeed = 850
var baseAirSpeed = 600
var damagePercent = 200.0
#walkforce is only used when no input is detected to slow the character down
var disableInputInfluence = 1200
var walkMaxSpeed = 300
var runMaxSpeed = 600
var airMaxSpeed = 500
var airStopForce = 450
var maxFallSpeed = 1800
var groundStopForce = 1500
var jumpSpeed = 800
var shortHopSpeed = 600
var fallingSpeed = 1.0
var currentMaxSpeed = baseWalkMaxSpeed
var pushingAction = false
var droppedPlatform = false
var walkThreashold = 0.15
#jump
var jumpCount = 0
var availabelJumps = 10
var airTime = 0
var abovePlatGround = null
#platform
var platformCollision = null
var atPlatformEdge = null
var lowestCheckYPoint 
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
var dashAttackSpeed = 800
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
var tumblingThreashold = 500
var characterBouncing = false
var lastVelocity = Vector2.ZERO
var bounceThreashold = 800
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
onready var grabPoint = get_node("GrabPoint")
#character stats
var weight = 1
var fastFallGravity = 4000
onready var gravity = 2000
onready var baseGravity = gravity
#hitlag 
var backUpHitStunTime = 0
var backUpDisableInputDI = false
var hitlagDI = Vector2.ZERO
var hitLagFrames = 60.0/60.0
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

var state_factory 
onready var animatedSprite = get_node("AnimatedSprite")
var applySideStepFrames = true
var bufferedInputSmashAttack = false
var bufferPlatformCollisionDisabledFrames = 0
var edgeRegrabTimer = null
var getUpType = null
var characterTargetGetUpPosition = null
var grabFrames = 60.0/60.0
var hitLagTimer
var bufferHitLagFrames = 0
#var bufferFTiltWalk = false
var stopAreaEntered = false
var invincibilityTimer = null
var applyLandingLag = null
var inLandingLag = false
var queueFreeFall = false
var bufferMoveAirTransition = false
#last bounce collision platform 
var lastBounceCollision = null

func _ready():
	self.set_collision_mask_bit(0,false)
	self.set_collision_mask_bit(2,true)
	#self.set_collision_mask_bit(1,false)
	var file = File.new()
	file.open("res://Characters/Mario/marioAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
	#assign nodes easy vars
	edgeGrabShape = $CharacterEdgeGrabArea/CharacterEdgeGrabShape
	lowestCheckYPoint = $LowestCheckYPoint
	collisionAreaShape = $InteractionAreas/CollisionArea/CollisionArea
	characterSprite = $AnimatedSprite
	animationPlayer = $AnimatedSprite/AnimationPlayer
	hurtBox = $InteractionAreas/Hurtbox
	tween = $Tween
	edgeRegrabTimer = create_timer("on_edgeRegrab_timeout", "EdgeRegrabTimer") 
	animationPlayer.set_animation_process_mode(0)
	GlobalVariables.charactersInGame.append(self)
	state_factory = StateFactory.new()
	if !onSolidGround:
		change_state(GlobalVariables.CharacterState.AIR)
	
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
	disableInput = true
	onEdge = true
	velocity = Vector2.ZERO
	jumpCount = 1
	snappedEdge = collidingEdge
	if currentMoveDirection == GlobalVariables.MoveDirection.RIGHT && collidingEdge.edgeSnapDirection == "right": 
		currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		state.mirror_areas()
	elif currentMoveDirection == GlobalVariables.MoveDirection.LEFT && collidingEdge.edgeSnapDirection == "left": 
		currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		state.mirror_areas()
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
	invincibilityTimer.stop_timer()
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
	match step:
		0:
			disabledEdgeGrab = false
			if !state.bufferedInput:
				match currentState:
					GlobalVariables.CharacterState.ATTACKGROUND:
						applySideStepFrames = true
						smashAttack = null
						if !state.check_character_crouch():
							change_state(GlobalVariables.CharacterState.GROUND)
						disableInput = false
					GlobalVariables.CharacterState.ATTACKAIR:
						change_state(GlobalVariables.CharacterState.AIR)
						smashAttack = null
			else:
				state.enable_player_input()

func apply_attack_animation_steps(step = 0):
	pass
	
func is_attacked_handler(damage, hitStun, launchVectorX, launchVectorY, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackedByCharacter):
	lastBounceCollision = null
	damagePercent += damage
	if weightLaunchVelocity == 0:
		attackedCalculatedVelocity = calculate_attack_knockback(damage, launchVelocity, knockBackScaling)
	else:
		attackedCalculatedVelocity = calculate_attack_knockback_weight_based(damage, weightLaunchVelocity, knockBackScaling)
	#print(damagePercent)
	velocity = Vector2.ZERO
	initLaunchVelocity = Vector2(launchVectorX,launchVectorY) * attackedCalculatedVelocity
	print("is attacked velocity " +str(Vector2(launchVectorX,launchVectorY)))
	#collisionAreaShape.set_deferred('disabled',true)
	if launchVelocity > tumblingThreashold || currentState == GlobalVariables.CharacterState.INGRAB:
	#todo: calculate if in tumble animation
		shortHitStun = false
	else: 
		shortHitStun = true
	backUpHitStunTime = hitStun/60.0
	#todo: reset other timers and set paramteres to null
	if characterShield.shieldBreak:
		characterShield.shieldBreak_end()
		
func is_attacked_handler_perfect_shield():
	#todo: add perfect shield animation and particle effects
	print("perfect shield")
	
func is_attacked_in_shield_handler(damage, shieldStunMultiplier, shieldDamage, isProjectile, attackedByCharacter):
	shieldStunFrames = int(floor(damage * 0.8 * shieldStunMultiplier + 2))/60.0
	characterShield.buffer_shield_damage(damage, shieldDamage)
#	characterShield.apply_shield_damage(damage, shieldDamage)
	#todo: calculate shield hit pushback
	var pushBack = 0
	velocity = Vector2.ZERO
	var pushDirection = 1
	if attackedByCharacter.global_position.x <= self.global_position.x:
		pushDirection = 1
	elif attackedByCharacter.global_position.x >= self.global_position.x:
		pushDirection = -1
	initLaunchVelocity = pushDirection * Vector2(400, 0)
	#((damage * parameters.shield.mult * projectileMult * perfectshieldMult * groundedMult * aerialMult) + parameters.shield.constant) * 0.09 * perfectshieldMult2;
	
func calculate_attack_knockback(attackDamage, attackBaseKnockBack, knockBackScaling):
#	print("CALCULATING")
	var calculatedKnockBack = (((((damagePercent/2+(damagePercent*attackDamage)/4)*200/(weight*100/2+100)*1.4)+18)*knockBackScaling)+(attackBaseKnockBack))*1
	#print("calculatedKnockBack " +str(calculatedKnockBack))
	return calculatedKnockBack
	
func calculate_attack_knockback_weight_based(attackDamage, attackBaseKnockBack, knockBackScaling):
	knockBackScaling = 1
	var calculatedKnockBack = (((((attackDamage/2+(attackDamage*attackDamage)/4)*200/(1*100/2+100)*1.4)+18)*knockBackScaling)+(attackBaseKnockBack))*1
	print("calculatedKnockBackWeightBased " +str(calculatedKnockBack))
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
	change_state(GlobalVariables.CharacterState.HITSTUNAIR)
	is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, inGrabByCharacter)
#	if shortHitStun:
#		state.play_animation("hurt_short")
#	elif !shortHitStun:
#		state.play_animation("hurt")
#	state.create_hitlagAttacked_timer(hitLagFrames)
#	inGrabByCharacter = null
	
func tech_handler_air(delta):
	print("tech handler air")
	
func tech_handler_ground(delta):
	print("tech handler ground")

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
			$AnimatedSprite.set_rotation_degrees(0.0)
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
			elif !state.bufferedInput:
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)
			else:
				state.enable_player_input()
			
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
			if !state.bufferedInput:
				applySideStepFrames = true
				velocity = Vector2.ZERO
				change_state(GlobalVariables.CharacterState.GROUND)
			else:
				velocity = Vector2.ZERO
				state.enable_player_input()

func jump_getup_animation_step(step = 0):
	match step:
		0:
			if !state.bufferedInput:
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
				state.enable_player_input()

			
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
			elif !state.bufferedInput:
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)
			else:
				state.enable_player_input()

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
			elif !state.bufferedInput:
				applySideStepFrames = true
				change_state(GlobalVariables.CharacterState.GROUND)
			else:
				state.enable_player_input()
				
func apply_tech_animation_step_air(step = 0):
	match step: 
		0: 
			disableInput = true
		1:
			state.bufferedInput = GlobalVariables.CharacterAnimations.JUMP
			if !state.bufferedInput:
				change_state(GlobalVariables.CharacterState.AIR)
			else:
				state.enable_player_input()

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
			
			
func check_state_transition(changeToState, bufferedInput):
	if bufferMoveAirTransition:
		bufferMoveAirTransition = false
		match currentState:
			GlobalVariables.CharacterState.ATTACKGROUND:
				if changeToState == GlobalVariables.CharacterState.AIR:
					bufferedInput = currentAttack
					changeToState = GlobalVariables.CharacterState.ATTACKAIR
			GlobalVariables.CharacterState.SHIELD:
				if changeToState == GlobalVariables.CharacterState.AIR:
					print("AIRDODGE")
	#				bufferedInput = currentAttack
	#				changeToState = GlobalVariables.CharacterState.ATTACKAIR
	return [bufferedInput, changeToState]
	

func change_state(new_state):
	var changeToState = new_state
	var bufferedInput = null
	var bufferedAnimation = null
	enable_disable_hurtboxes(true)
#	check_character_tilt_walk(new_state)
	if state != null:
		bufferedInput = state.bufferedInput
		var checkedTransition = check_state_transition(changeToState, bufferedInput)
		bufferedInput = checkedTransition[0]
		changeToState = checkedTransition[1]
		currentAttack = null
		bufferedAnimation = state.bufferedAnimation
		state.stateDone = true
		state.queue_free()
	print(self.name + " Changing to " +str(GlobalVariables.CharacterState.keys()[changeToState]))
	state = state_factory.get_state(changeToState).new()
	state.setup(funcref(self, "change_state"), animationPlayer, self, bufferedInput, bufferedAnimation)
	toggle_all_hitboxes("off")
	currentState = changeToState
	emit_signal("character_state_changed", self, currentState)
	add_child(state)
	
#func check_character_tilt_walk(new_state):
#	if currentState == GlobalVariables.CharacterState.ATTACKGROUND\
#	&& currentAttack == GlobalVariables.CharacterAnimations.FTILTL\
#	|| currentAttack == GlobalVariables.CharacterAnimations.FTILTR:
#		if new_state == GlobalVariables.CharacterState.GROUND:
#			bufferFTiltWalk = true

func create_timer(timeout_function, timerName):
	var timer = Timer.new()    
	timer.set_name(timerName)
	add_child (timer)
	timer.connect("timeout", self, timeout_function) 
	return timer

func create_edgeRegrab_timer(waitTime):
	disabledEdgeGrab = true
	edgeGrabShape.set_deferred("disabled", true)
	edgeRegrabTimer.set_one_shot(true)
	edgeRegrabTimer.start(waitTime)

func on_edgeRegrab_timeout():
	disabledEdgeGrab = false
	if currentState == GlobalVariables.CharacterState.AIR && state.get_input_direction_y() < 0.5:
		edgeGrabShape.set_deferred("disabled", false)

func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.set_deferred('disabled',false)
		"off":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.set_deferred('disabled',true)
			$InteractionAreas.set_position(Vector2(0,0))
			$InteractionAreas.set_rotation(0)

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
		
func character_attacked_handler(hitLagFrames):
	bufferHitLagFrames = hitLagFrames
	if !perfectShieldActivated:
		change_state(GlobalVariables.CharacterState.HITSTUNAIR)
	else:
		state.create_hitlagAttacked_timer(bufferHitLagFrames)
		
func character_attacked_shield_handler(hitLagFrames):
	bufferHitLagFrames = hitLagFrames
	change_state(GlobalVariables.CharacterState.SHIELDSTUN)
	
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
