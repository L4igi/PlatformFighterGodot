extends Projectile

class_name FireBall
	
func set_base_stats():
	gravity = 1000.0
	baseGravity = 1000.0
	initLaunchVelocity = 0.0
#	var airStopForce = 100
	airMaxSpeed = 200
	maxFallSpeed = 10000
	velocity = Vector2(airMaxSpeed,0)
	self.name = "Fireball"
	deleteOnImpact = true
	set_collision_mask_bit(0,false)
	
func process_projectile_physics(_delta):
#	projectile.velocity.x = move_toward(projectile.velocity.x, 0, projectile.airStopForce * _delta)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	calculate_vertical_velocity(_delta)
	velocity = move_and_slide(velocity)  
	if check_ground_platform_collision():
		velocity.y = -400

#func on_impact():
#	toggle_all_hitboxes("off")
#	change_state(GlobalVariables.ProjectileState.IMPACT)
#	projectilecollider.set_deferred("disabled", true)
