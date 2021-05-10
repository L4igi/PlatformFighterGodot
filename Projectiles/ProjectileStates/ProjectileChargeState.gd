extends ProjectileState

class_name ProjectileChargeState

func _ready():
	projectile.velocity = Vector2.ZERO
	play_animation("charge")
	
func setup(change_state, animationPlayer, projectile):
	.setup(change_state, animationPlayer, projectile)
	projectile.toggle_all_hurtboxes("off")
	projectile.toggle_all_hitboxes("off")

