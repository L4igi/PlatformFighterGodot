extends Projectile

class_name Arrow

func _ready():
	var file = File.new()
	file.open("res://Projectiles/Arrow/ArrowAttack.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	change_state(Globals.ProjectileState.SHOOT)
	
func set_base_stats(parentNode, originalOwner):
	ttlFrames = 300.0
	baseGravity = 1000.0
	airStopForce = 400
	gravity = 350.0
	airMaxSpeed = 800
	baseAirMaxSpeed = 1700
	maxFallSpeed = 5000
	global_position = parentNode.interactionPoint.global_position
	grabAble = false
	canHitSelf = false
	deleteOnImpact = false
	ttlTimeoutAction = Globals.ProjectileState.DESTROYED
	create_projectileTTL_timer(ttlFrames)
	airMaxSpeed = clamp(airMaxSpeed * currentCharge *1.3, -baseAirMaxSpeed, baseAirMaxSpeed)
	.set_base_stats(parentNode, originalOwner)
	
func process_projectile_physics(_delta):
	velocity.x = move_toward(velocity.x, 0, airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)  
	
func _physics_process(_delta):
	._physics_process(_delta)
#	print(projectileTTLTimer.get_time_left()*60)


func on_impact():
	match projectileSpecialInteraction:
		Globals.ProjectileInteractions.REFLECTED:
			change_state(Globals.ProjectileState.SHOOT)
		Globals.ProjectileInteractions.ABSORBED:
			print("bomb on impact ABSORBED " +str(parentNode.name))
		Globals.ProjectileInteractions.COUNTERED:
			print("bomb on impact COUNTERED " +str(parentNode.name))
		Globals.ProjectileInteractions.DESTROYED:
			print("bomb on impact DESTROYED " +str(parentNode.name))
		Globals.ProjectileInteractions.IMPACTED:
			print("bomb on impact IMPACTED " +str(parentNode.name))
		Globals.ProjectileInteractions.CONTINOUS:
			pass
		Globals.ProjectileInteractions.CATCH:
			print("bomb on impact Catch " +str(parentNode.name))
			change_state(Globals.ProjectileState.HOLD)
		Globals.ProjectileInteractions.HITOTHERCHARACTER:
			pass
		Globals.ProjectileInteractions.HITOTHERCHARACTERSHIELD:
			if currentState != Globals.ProjectileState.IMPACT:
				print("bomb hit other character shield " +str(interactionObject))
				bounce_projectile_relative_to_object(interactionObject)
				interactionObject = null
				toggle_all_hitboxes("off")
				state.play_animation("shoot_no_hitbox")
		_:
			change_state(Globals.ProjectileState.DESTROYED)
	projectileSpecialInteraction = null

func projectile_touched_solid_ground():
	on_impact()


func apply_special_hitbox_effect_attacked(effectArray, interactionObject, attackingDamage, interactionType):
	print(self.name + " apply_special_hitbox_effect " +str(effectArray) + " " +str(interactionObject.name) + " dmg " +str(attackingDamage) + " interactiontype " +str(interactionType))
	var projectileInteracted = false
	for effect in effectArray:
		match effect: 
			Globals.SpecialHitboxType.REVERSE:
				if handle_effect_reflect_attacked(interactionType, interactionObject, attackingDamage):
					projectileInteracted = true
			Globals.SpecialHitboxType.REFLECT:
				if handle_effect_reflect_attacked(interactionType, interactionObject, attackingDamage):
					projectileInteracted = true
			Globals.SpecialHitboxType.ABSORB:
				pass
#				handle_effect_absorb_attacking(interactionType, attackedObject, attackingDamage)
			Globals.SpecialHitboxType.COUNTER:
				pass
#				handle_effect_counter_attacking(interactionType, attackedObject, attackingDamage)
			Globals.SpecialHitboxType.FIRE:
				projectileInteracted = true
				projectileSpecialInteraction = null
			Globals.SpecialHitboxType.BOMB:
				projectileSpecialInteraction = Globals.ProjectileInteractions.CONTINOUS
				projectileInteracted = true
	return projectileInteracted

#func check_projectile_projectile_no_interaction(interactionObject):
#	if interactionObject.
