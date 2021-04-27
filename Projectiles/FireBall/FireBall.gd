extends Projectile

class_name FireBall

func _ready():
	var file = File.new()
	file.open("res://Projectiles/FireBall/FireBallAttacks.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	attackData = jsondata.get_result()
	
func set_base_stats(parentNode):
	gravity = 2000.0
	baseGravity = 2000.0
	initLaunchVelocity = 0.0
#	var airStopForce = 100
	airMaxSpeed = 200
	baseAirMaxSpeed = 500
	maxFallSpeed = 10000
	bounceVelocity = 600
	match parentNode.currentMoveDirection: 
		GlobalVariables.MoveDirection.LEFT:
			velocity = Vector2(-airMaxSpeed,0)
		GlobalVariables.MoveDirection.RIGHT:
			velocity = Vector2(airMaxSpeed,0)
	currentMoveDirection = parentNode.currentMoveDirection
	self.name = "Fireball"
	deleteOnImpact = true
	set_collision_mask_bit(0,false)
	canHitSelf = false
	if !canHitSelf: 
		self.parentNode = parentNode
	
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
	if projectileSpecialInteraction == GlobalVariables.SpecialHitboxType.REFLECT:
		print("fireball on impact special " +str(parentNode.name))
		projectileSpecialInteraction = null
	else:
		print("fireball on impact not special " +str(parentNode.name))
		toggle_all_hitboxes("off")
		change_state(GlobalVariables.ProjectileState.IMPACT)
		projectilecollider.set_deferred("disabled", true)