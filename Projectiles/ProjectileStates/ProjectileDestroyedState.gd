extends ProjectileState

class_name ProjectileDestroyedState

func _ready():
	projectile.deleteOnImpact = true
	animationPlayer.play("impact")
	
func setup(change_state, animationPlayer, projectile):
	.setup(change_state, animationPlayer, projectile)
	
