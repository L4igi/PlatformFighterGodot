extends Projectile

class_name ChargeShot

var chargeMode = 1

func _ready():
	var file = File.new()
	file.open("res://Projectiles/ChargeShot/ChargeShot.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	
func set_base_stats(parentNode, originalOwner):
	ttlFrames = 300.0
	canHitSelf = false
	.set_base_stats(parentNode, originalOwner)
	airMaxSpeed = 500
	baseAirMaxSpeed = 500
	maxFallSpeed = 0
	bounceVelocity = 0
	grabAble = false
	deleteOnImpact = true
	global_position = parentNode.interactionPoint.global_position
	ttlTimeoutAction = GlobalVariables.ProjectileState.IMPACT
	solidGroundInteractionThreasholdY = 550.0
	projectileReflectVelocityY = 0
	ttlFrames = 240
	projectilePushVelocity = 200
	parentNode.chargingProjectile = self
	set_collision_mask_bit(1,false)
	change_state(GlobalVariables.ProjectileState.CHARGE)
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
#	calculate_vertical_velocity(_delta)
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
			pass
		GlobalVariables.ProjectileInteractions.HITOTHERCHARACTER:
			deleteOnImpact = true
#			parentNode = null
#			originalOwner = null
			change_state(GlobalVariables.ProjectileState.IMPACT)
			projectilecollider.set_deferred("disabled", true)
		GlobalVariables.ProjectileInteractions.HITOTHERCHARACTERSHIELD:
			pass
		_:
#			print("bomb on impact " +str(interactionObject.name))
#			print("bomb on impact not special " +str(parentNode.name))
			deleteOnImpact = true
			parentNode = null
			originalOwner = null
			change_state(GlobalVariables.ProjectileState.IMPACT)
			projectilecollider.set_deferred("disabled", true)
	projectileSpecialInteraction = null

func check_ground_platform_collision():
	if get_slide_count():
		var collision = get_slide_collision(0)
		if collision.get_collider().is_in_group("Ground"):
			var roundedCollisionNormal = Vector2(stepify(collision.get_normal().x, 0.01),stepify(collision.get_normal().y, 0.01))
			if roundedCollisionNormal != Vector2(0,1)\
			&& roundedCollisionNormal != Vector2(0,-1):
				platformCollision = collision.get_collider()
				return platformCollision
	return null

func projectile_touched_solid_ground():
	on_impact()

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
				pass
	return projectileInteracted

func charge_projectile(mode):
	self.set_scale(Vector2(currentCharge, currentCharge))
	.charge_projectile(mode)

func check_fully_charged(step):
	if currentCharge >= maxCharge: 
		if step == 1:
			shoot_charge_projectile()
		return true
	return false
