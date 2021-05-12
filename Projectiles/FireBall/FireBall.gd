extends Projectile

class_name FireBall

func _ready():
	var file = File.new()
	file.open("res://Projectiles/FireBall/FireBallAttacks.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	change_state(GlobalVariables.ProjectileState.SHOOT)
	
func set_base_stats(parentNode, originalOwner):
	ttlFrames = 180.0
	.set_base_stats(parentNode, originalOwner)
	gravity = 2000.0
	baseGravity = 2000.0
#	var airStopForce = 100
	airMaxSpeed = 200
	baseAirMaxSpeed = 500
	maxFallSpeed = 1000
	bounceVelocity = 600
	global_position = parentNode.interactionPoint.global_position
	grabAble = false
	canHitSelf = false
	deleteOnImpact = true
	ttlTimeoutAction = GlobalVariables.ProjectileState.DESTROYED
	create_projectileTTL_timer(ttlFrames)
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)  
	if check_ground_platform_collision():
		airMaxSpeed = baseAirMaxSpeed
		velocity = velocity.bounce(Vector2(0,-1))
		velocity.y = -bounceVelocity

func on_impact():
	match projectileSpecialInteraction:
		GlobalVariables.ProjectileInteractions.REFLECTED:
			print("fireball on impact REFLECTED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.ABSORBED:
			print("fireball on impact ABSORBED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.COUNTERED:
			print("fireball on impact COUNTERED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.DESTROYED:
			print("fireball on impact DESTROYED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.IMPACTED:
			print("fireball on impact IMPACTED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.CONTINOUS:
			print("fireball on impact CONTINOUS " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.HITOTHERCHARACTER:
			toggle_all_hitboxes("off")
			change_state(GlobalVariables.ProjectileState.DESTROYED)
			projectilecollider.set_deferred("disabled", true)
		_:
			print("fireball on impact not special " +str(parentNode.name))
			toggle_all_hitboxes("off")
			change_state(GlobalVariables.ProjectileState.DESTROYED)
			projectilecollider.set_deferred("disabled", true)
	projectileSpecialInteraction = null

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
				pass
			GlobalVariables.SpecialHitboxType.BOMB:
				projectileInteracted = true 
				projectileSpecialInteraction = null
	return projectileInteracted
