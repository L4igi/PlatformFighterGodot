extends Projectile

class_name Bomb

func _ready():
	var file = File.new()
	file.open("res://Projectiles/Bomb/BombAttack.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	
func set_base_stats(parentNode, originalOwner):
	.set_base_stats(parentNode, originalOwner)
#	gravity = 200.0
#	baseGravity = 400.0
#	var airStopForce = 100
	airMaxSpeed = 500
	baseAirMaxSpeed = 500
	maxFallSpeed = 2000
	bounceVelocity = 100
	grabAble = true
	canHitSelf = false
	deleteOnImpact = false
	global_position = parentNode.interactionPoint.global_position
	change_state(GlobalVariables.ProjectileState.HOLD)
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)  
	

func on_impact():
	match projectileSpecialInteraction:
		GlobalVariables.ProjectileInteractions.REFLECTED:
			print("bomb on impact REFLECTED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.ABSORBED:
			print("bomb on impact ABSORBED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.COUNTERED:
			print("bomb on impact COUNTERED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.DESTROYED:
			print("bomb on impact DESTROYED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.IMPACTED:
			print("bomb on impact IMPACTED " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.CONTINOUS:
			print("bomb on impact CONTINOUS " +str(parentNode.name))
		GlobalVariables.ProjectileInteractions.CATCH:
			print("bomb on impact Catch " +str(parentNode.name))
#			projectile.on_projectile_catch()
		_:
			print("bomb on impact not special " +str(parentNode.name))
			toggle_all_hitboxes("off")
			deleteOnImpact = true
			change_state(GlobalVariables.ProjectileState.IMPACT)
			projectilecollider.set_deferred("disabled", true)
	projectileSpecialInteraction = null
