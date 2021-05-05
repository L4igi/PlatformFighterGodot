extends ProjectileState

class_name ProjectileImpactState

func _ready():
	animationPlayer.play("impact")
	
func setup(change_state, animationPlayer, projectile):
	projectile.currentAttack = GlobalVariables.ProjectileAnimations.IMPACT
	.setup(change_state, animationPlayer, projectile)
