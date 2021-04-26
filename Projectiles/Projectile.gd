extends KinematicBody2D

class_name Projectile

var currentHitBox = 1
var currentState = null
var currentAttack = null
var currentMoveDirection = null
var grabAble = false
var damage = 0.0
var velocity = Vector2.ZERO
var bounce = false
var deleteOnImpact = false
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
var gravity = 1000.0
var baseGravity = 1000
var initLaunchVelocity = 0.0
var airStopForce = 100
var airMaxSpeed = 100
var maxFallSpeed = 100
#inputs 
var disableInput = true
var backUpDisableInput = false
#hitlag
var hitLagFrames = 2.0
#collisions 
var platformCollision = null
#parent 
var parent = null
#hitboxes and hurtboxes 
onready var projectilecollider = get_node("ProjectileCollider")

func _ready():
	self.set_collision_mask_bit(1,true)
	self.set_collision_mask_bit(2,true)
	var file = File.new()
	file.open("res://Projectiles/FireBall//FireBallAttacks.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	attackDataEnum = GlobalVariables.ProjectileAnimations
	animationPlayer.set_animation_process_mode(0)
	state_factory = ProjectileStateFactory.new()
	change_state(GlobalVariables.ProjectileState.SHOOT)
	set_base_stats()
	
func _physics_process(delta):
	stateChangedThisFrame = false
	
func set_base_stats():
	pass

func setup_parent(parent):
	pass
	
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
	
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)     

func calculate_vertical_velocity(_delta):
	velocity.y += gravity * _delta
	if velocity.y >= maxFallSpeed: 
		velocity.y = maxFallSpeed

func apply_special_hitbox_effect_attacked(effectArray, attackingObject, attackingDamage, interactionType):
	print(self.name + " is apply_special_hitbox_effect_attacked " +str(effectArray) + " " +str(attackingObject.name) + " dmg " +str(attackingDamage) + " interactiontype " +str(interactionType))
#	for effect in effectArray:
#		match effect: 
#			GlobalVariables.SpecialHitboxType.REVERSE:
#				handle_effect_reverse_attacked(interactionType, attackingObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.REFLECT:
#				handle_effect_reflect_attacked(interactionType, attackingObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.ABSORB:
#				handle_effect_absorb_attacked(interactionType, attackingObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.COUNTER:
#				handle_effect_counter_attacked(interactionType, attackingObject, attackingDamage)
func apply_special_hitbox_effect_attacking(effectArray, attackedObject, attackingDamage, interactionType):
	print(self.name + " apply_special_hitbox_effect_attacking " +str(effectArray) + " " +str(attackedObject.name) + " dmg " +str(attackingDamage) + " interactiontype " +str(interactionType))
#	for effect in effectArray:
#		match effect: 
#			GlobalVariables.SpecialHitboxType.REVERSE:
#				handle_effect_reverse_attacking(interactionType, attackedObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.REFLECT:
#				handle_effect_reflect_attacking(interactionType, attackedObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.ABSORB:
#				handle_effect_absorb_attacking(interactionType, attackedObject, attackingDamage)
#			GlobalVariables.SpecialHitboxType.COUNTER:
#				handle_effect_counter_attacking(interactionType, attackedObject, attackingDamage)

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

func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						#todo: maybe change this to handle special hitboxes differently
						if !hitbox.is_in_group("SpecialHitBox"):
							hitbox.set_deferred('disabled',false)
		"off":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.set_deferred('disabled',true)
