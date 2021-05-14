class_name ProjectileStateFactory

var states

func _init():
	states = {
		Globals.ProjectileState.CONTROL: ProjectileControlState, 
		Globals.ProjectileState.SHOOT: ProjectileShootState, 
		Globals.ProjectileState.IMPACT: ProjectileImpactState, 
		Globals.ProjectileState.DESTROYED: ProjectileDestroyedState, 
		Globals.ProjectileState.HOLD: ProjectileHoldState, 
		Globals.ProjectileState.CHARGE: ProjectileChargeState, 
		Globals.ProjectileState.IDLE: ProjectileIdleState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
