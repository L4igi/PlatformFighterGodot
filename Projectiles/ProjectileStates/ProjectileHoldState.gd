extends ProjectileState

class_name ProjectileHoldState

func _ready():
	play_animation("hold")
	
func setup(change_state, animationPlayer, projectile):
	.setup(change_state, animationPlayer, projectile)
	projectile.toggle_all_hurtboxes("off")
	projectile.toggle_all_hitboxes("off")

