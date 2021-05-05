extends ProjectileState

class_name ProjectileShootState

func _ready():
	play_animation("shoot")
	
func setup(change_state, animationPlayer, projectile):
	.setup(change_state, animationPlayer, projectile)
	projectile.currentAttack = GlobalVariables.ProjectileAnimations.SHOOT
	projectile.toggle_all_hurtboxes("off")

func _physics_process(_delta):
	if !stateDone:
		projectile.manage_projectile_physics(_delta)
