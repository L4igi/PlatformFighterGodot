class_name ProjectileStateFactory

var states

func _init():
	states = {
		GlobalVariables.ProjectileState.CONTROL: ProjectileControlState, 
		GlobalVariables.ProjectileState.SHOOT: ProjectileShootState, 
		GlobalVariables.ProjectileState.IMPACT: ProjectileImpactState 
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
