extends ProjectileState

class_name ProjectileShootState

func _ready():
	pass
	
func setup(change_state, animationPlayer, projectile):
	.setup(change_state, animationPlayer, projectile)
	projectile.toggle_all_hurtboxes("on")
	projectile.toggle_all_hitboxes("on")
	projectile.currentAttack = GlobalVariables.ProjectileAnimations.SHOOT

func _physics_process(_delta):
	if !stateDone:
		projectile.process_projectile_physics(_delta)
