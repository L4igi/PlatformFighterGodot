extends KinematicBody2D

class_name Projectile

var currentHitBox = 1
var currentState = null
var currentAttack = null
var currentMoveDirection = null
var grabAble = false
var damage = 0.0
var velocity = Vector2.ZERO
var bounceVelocity = 0.0
var deleteOnImpact = false
var canHitSelf = false
var destroyOnParentImpact = false
#state changer 
var state_factory = null
var state = null
var stateChangedThisFrame = false
#animations 
onready var animatedSprite = get_node("AnimatedSprite")
onready var animationPlayer = get_node("AnimatedSprite/AnimationPlayer")
#json data
var attackData = null
var attackDataEnum
#buffers 
var bufferedAnimation = null
#attributes 
var gravity = 2000.0
var baseGravity = 2000
var initLaunchVelocity = null
var airMaxSpeed = 100
var maxFallSpeed = 100
var baseAirMaxSpeed = 100
var airStopForce = 150
var groundStopForce = 500
#inputs 
var disableInput = true
var backUpDisableInput = false
#hitlag
var hitLagFrames = 3.0
#collisions 
var platformCollision = null
var onSolidGround = null
#parent 
var parentNode = null
#hitboxes and hurtboxes 
onready var projectilecollider = get_node("ProjectileCollider")
#interactionobject
var projectileSpecialInteraction = null
#chargeable projectile
var currentCharge = 0.0
var maxCharge = 0.0
var chargeTickRate = 0.0
#original owner 
var originalOwner = null
#projectile ttl timer
var projectileTTLTimer = null
#backup disabled hitboxes
var backupDisabledHitboxes = []
#shows if projectile was thrown 
var projectileThrown = false
#projectile already caught 
var projectileCaughtThisFrame = false
#hitboxes 
onready var neutralHitbox = get_node("AnimatedSprite/HitBoxes/HitBoxNeutralArea/Neutral")
#impact or destroy(no hitbox) on ttl timeout
var ttlTimeoutAction = GlobalVariables.ProjectileState.DESTROYED
var ttlFrames = 10.0
#last velocity non zero for impact calculations 
var lastVelocityNotZero = Vector2.ZERO
var solidGroundInteractionThreasholdY = 550.0
#var projectilereflectvelocity
var projectileReflectVelocityY= -500
#when projectile bounces on character shield, save bounce character node 
var interactionObject = null
#solidgroundInitBounceVelocity 
var solidGroundInitBounceVelocity = 100

var multiObjectsConnected = false 

func _ready():
	self.set_collision_mask_bit(0,false)
	self.set_collision_mask_bit(1,true)
	self.set_collision_mask_bit(2,true)
	attackDataEnum = GlobalVariables.ProjectileAnimations
	animationPlayer.set_animation_process_mode(0)
	state_factory = ProjectileStateFactory.new()
	
	
func _physics_process(delta):
	projectileCaughtThisFrame = false
	stateChangedThisFrame = false
	
func set_base_stats(parentNode, originalOwner):
	self.global_position = parentNode.interactionPoint.global_position
	match parentNode.currentMoveDirection: 
		GlobalVariables.MoveDirection.LEFT:
			velocity = Vector2(-airMaxSpeed,0)
		GlobalVariables.MoveDirection.RIGHT:
			velocity = Vector2(airMaxSpeed,0)
	currentMoveDirection = parentNode.currentMoveDirection
	set_collision_mask_bit(0,false)
	if !canHitSelf: 
		self.parentNode = parentNode
		self.originalOwner = originalOwner
	create_projectileTTL_timer(ttlFrames)
	
func change_parent():
	pass
	

func change_state(new_state):
	if currentState == new_state:
		state.switch_to_current_state_again()
		return
	if stateChangedThisFrame:
		print(str(GlobalVariables.ProjectileState.keys()[new_state]) +" State already changed this frame ")
		return
	stateChangedThisFrame = true
	var changeToState = new_state
#	check_character_tilt_walk(new_state)
	if state != null:
		state.stateDone = true
#		changeToState = check_state_transition(changeToState)
#		bufferedAnimation = state.bufferedAnimation
		state.queue_free()
#		if state.is_queued_for_deletion():
#			print(str(state.name) +" STATE CAN BE QUEUED FREE AFTER FRAME")
#		else:
#			print(str(state.name) +"STATE CANNOT BE QUEUED FREE AFTER FRAME")
	print(self.name + " Changing to " +str(GlobalVariables.ProjectileState.keys()[changeToState]))
	state = state_factory.get_state(changeToState).new()
	state.name = GlobalVariables.ProjectileState.keys()[new_state]
#	if state.get_parent():
#		print("currentstate " +str(currentState) + " new state " +str(new_state))
#		print("state " +str(GlobalVariables.CharacterState.keys()[changeToState]) + " already has parent " +str(state.get_parent()))
	state.setup(funcref(self, "change_state"),animationPlayer, self)
	currentState = changeToState
	add_child(state)
	
func manage_projectile_physics(_delta):
	if velocity.y > 0.0:
		lastVelocityNotZero = velocity
	if projectileThrown:
		process_projectile_physics_thrown(_delta)
	else:
		process_projectile_physics(_delta)
	if check_ground_platform_collision():
		if !onSolidGround:
			projectile_touched_solid_ground()
		onSolidGround = true
	else:
		onSolidGround = false
	
func process_projectile_physics(_delta):
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)     
	
func process_projectile_physics_thrown(_delta):
	if onSolidGround:
		velocity.y = int(abs(lastVelocityNotZero.y) *-0.5)
		velocity.x = move_toward(velocity.x, 0, groundStopForce * _delta)
	else:
		velocity.x = move_toward(velocity.x, 0, airStopForce * _delta)
	calculate_vertical_velocity(_delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	velocity = move_and_slide(velocity)   

func calculate_vertical_velocity(_delta):
	velocity.y += gravity * _delta
	if velocity.y >= maxFallSpeed: 
		velocity.y = maxFallSpeed

func apply_special_hitbox_effect_attacked(effectArray, interactionObject, attackingDamage, interactionType):
	print(self.name + " apply_special_hitbox_effect " +str(effectArray) + " " +str(interactionObject.name) + " dmg " +str(attackingDamage) + " interactiontype " +str(interactionType))
	var projectileInteracted = false
	for effect in effectArray:
		match effect: 
			GlobalVariables.SpecialHitboxType.REVERSE:
				if handle_effect_reflect_attacked(interactionType, interactionObject, attackingDamage):
					projectileInteracted = true
			GlobalVariables.SpecialHitboxType.REFLECT:
				if handle_effect_reflect_attacked(interactionType, interactionObject, attackingDamage):
					projectileInteracted = true
			GlobalVariables.SpecialHitboxType.ABSORB:
				pass
#				handle_effect_absorb_attacking(interactionType, attackedObject, attackingDamage)
			GlobalVariables.SpecialHitboxType.COUNTER:
				pass
#				handle_effect_counter_attacking(interactionType, attackedObject, attackingDamage)
	return projectileInteracted

func handle_effect_reflect_attacked(interactionType, interactionObject, attackingDamage):
	projectileSpecialInteraction = GlobalVariables.ProjectileInteractions.REFLECTED
	lastVelocityNotZero = Vector2.ZERO
	match interactionObject.currentMoveDirection:
		GlobalVariables.MoveDirection.RIGHT:
			currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
			initLaunchVelocity = Vector2(baseAirMaxSpeed * 2, projectileReflectVelocityY)
		GlobalVariables.MoveDirection.LEFT:
			currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			initLaunchVelocity = Vector2(baseAirMaxSpeed * -2, projectileReflectVelocityY)
	parentNode = interactionObject
	return true

func check_ground_platform_collision():
	if velocity.y >= 0 && get_slide_count():
		var collision = get_slide_collision(0)
		if (collision.get_collider().is_in_group("Platform")\
		|| collision.get_collider().is_in_group("Ground"))\
		&& check_max_ground_radians(collision):
			platformCollision = collision.get_collider()
			return platformCollision
	return null
	
func check_max_ground_radians(collision):
	var collisionNoraml = collision.get_normal()
	var collisionNormalRadians = atan2(collisionNoraml.y, collisionNoraml.x)
	if collisionNormalRadians >= 0: 
		return false 
	return true

func on_impact():
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"impact":
			if deleteOnImpact: 
				self.queue_free()
		"destroy":
			self.queue_free()

func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						#todo: maybe change this to handle special hitboxes differently
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
						
func toggle_all_hurtboxes(onOff):
	match onOff: 
		"on":
			for hurtBox in $HurtBoxArea.get_children():
				if hurtBox is CollisionShape2D:
					#todo: maybe change this to handle special hitboxes differently
					hurtBox.set_deferred('disabled',false)
		"off":
			for hurtBox in $HurtBoxArea.get_children():
				if hurtBox is CollisionShape2D:
					#todo: maybe change this to handle special hitboxes differently
					hurtBox.set_deferred('disabled',true)

func check_hit_parentNode(object):
	if object == parentNode: 
		if destroyOnParentImpact: 
			change_state(GlobalVariables.ProjectileState.DESTROYED)
		return true
	else: 
		return false

func on_projectile_throw(throwType):
	projectileThrown = true
	parentNode.call_deferred("remove_child",self)
	GlobalVariables.currentStage.call_deferred("add_child",self)
	call_deferred("setup_throw_item",throwType)
	projectileSpecialInteraction = null
	change_state(GlobalVariables.ProjectileState.SHOOT)
	
func on_projectile_catch(newParent):
	if !projectileCaughtThisFrame:
		projectileCaughtThisFrame = true
		parentNode = newParent
		parentNode.grabbedItem = self
		GlobalVariables.currentStage.call_deferred("remove_child",self)
		newParent.call_deferred("add_child",self)
		set_deferred("global_position", newParent.global_position)
		projectileSpecialInteraction = GlobalVariables.ProjectileInteractions.CATCH
		on_impact()

func is_attacked_handler(hitLagFrames, attackingObject):
	state.create_hitlagAttacked_timer(hitLagFrames)

func is_attacked_handler_no_knockback(hitLagFrames, attackingObject):
	state.create_hitlagAttacked_timer(hitLagFrames)
	
func setup_throw_item(throwType):
	self.global_position = parentNode.interactionPoint.global_position
	currentMoveDirection = parentNode.currentMoveDirection
	var direction = Vector2(1,1)
	match parentNode.currentMoveDirection: 
		GlobalVariables.MoveDirection.LEFT:
			direction = Vector2(-1,1)
		GlobalVariables.MoveDirection.RIGHT:
			direction = Vector2(1,1)
	match throwType: 
		GlobalVariables.CharacterAnimations.THROWITEMDOWN:
			velocity = Vector2(0, 800)
		GlobalVariables.CharacterAnimations.THROWITEMUP:
			velocity = Vector2(0, -1000)
		GlobalVariables.CharacterAnimations.THROWITEMFORWARD:
			velocity = Vector2(1500, -400) * direction
		GlobalVariables.CharacterAnimations.ZDROPITEM: 
			velocity = Vector2(0,0)

func create_projectileTTL_timer(waittime):
	GlobalVariables.start_timer(projectileTTLTimer, waittime)

func on_projectileTTL_timeout():
	if currentState == GlobalVariables.ProjectileState.HOLD:
		parentNode.grabbedItem = null
	match ttlTimeoutAction:
		GlobalVariables.ProjectileState.DESTROYED: 
			change_state(GlobalVariables.ProjectileState.DESTROYED)
		GlobalVariables.ProjectileState.IMPACT: 
			on_impact()

func projectile_touched_solid_ground():
	pass
	
func bounce_projectile_relative_to_object(object):
	var bounceVector = (self.global_position-object.global_position).normalized()
	velocity = bounceVector * 300

func check_projectile_projectile_no_interaction(interactionObject):
	pass
