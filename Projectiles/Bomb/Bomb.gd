extends Projectile

class_name Bomb

func _ready():
	var file = File.new()
	file.open("res://Projectiles/Bomb/BombAttack.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	
func set_base_stats(parentNode, originalOwner):
	ttlFrames = 300.0
	.set_base_stats(parentNode, originalOwner)
#	gravity = 200.0
#	baseGravity = 400.0
#	var airStopForce = 100
	airMaxSpeed = 500
	baseAirMaxSpeed = 500
	maxFallSpeed = 2000
	bounceVelocity = 100
	groundStopForce = 10000
	grabAble = true
	canHitSelf = true
	deleteOnImpact = false
	global_position = parentNode.interactionPoint.global_position
	change_state(GlobalVariables.ProjectileState.HOLD)
	ttlTimeoutAction = GlobalVariables.ProjectileState.IMPACT
	solidGroundInteractionThreasholdY = 550.0
	projectileReflectVelocityY = -500
	create_projectileTTL_timer(ttlFrames)
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)  
	
func _physics_process(_delta):
	._physics_process(_delta)
#	print(projectileTTLTimer.get_time_left()*60)


func on_impact():
	match projectileSpecialInteraction:
		GlobalVariables.ProjectileInteractions.REFLECTED:
			change_state(GlobalVariables.ProjectileState.SHOOT)
		GlobalVariables.ProjectileInteractions.ABSORBED:
			print("bomb on impact ABSORBED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.COUNTERED:
			print("bomb on impact COUNTERED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.DESTROYED:
			print("bomb on impact DESTROYED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.IMPACTED:
			print("bomb on impact IMPACTED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.CONTINOUS:
			pass
		GlobalVariables.ProjectileInteractions.CATCH:
			print("bomb on impact Catch " +str(parentNode.name))
			change_state(GlobalVariables.ProjectileState.HOLD)
		GlobalVariables.ProjectileInteractions.HITOTHERCHARACTER:
			deleteOnImpact = true
#			parentNode = null
#			originalOwner = null
			change_state(GlobalVariables.ProjectileState.IMPACT)
			projectilecollider.set_deferred("disabled", true)
		GlobalVariables.ProjectileInteractions.HITOTHERCHARACTERSHIELD:
			if currentState != GlobalVariables.ProjectileState.IMPACT:
				print("bomb hit other character shield " +str(interactionObject))
				bounce_projectile_relative_to_object(interactionObject)
				interactionObject = null
				toggle_all_hitboxes("off")
				state.play_animation("shoot_no_hitbox")
		_:
#			print("bomb on impact " +str(interactionObject.name))
#			print("bomb on impact not special " +str(parentNode.name))
			deleteOnImpact = true
			parentNode = null
			originalOwner = null
			change_state(GlobalVariables.ProjectileState.IMPACT)
			projectilecollider.set_deferred("disabled", true)
	projectileSpecialInteraction = null

func projectile_touched_solid_ground():
	if lastVelocityNotZero.y > solidGroundInteractionThreasholdY\
	&& projectileThrown: 
		on_impact()
	else: 
		toggle_all_hitboxes("off")
		state.play_animation("shoot_no_hitbox")
		velocity.y = -solidGroundInitBounceVelocity

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
			GlobalVariables.SpecialHitboxType.FIRE:
				projectileInteracted = true
				projectileSpecialInteraction = null
			GlobalVariables.SpecialHitboxType.BOMB:
				projectileSpecialInteraction = GlobalVariables.ProjectileInteractions.CONTINOUS
				projectileInteracted = true
	return projectileInteracted

#func check_projectile_projectile_no_interaction(interactionObject):
#	if interactionObject.
