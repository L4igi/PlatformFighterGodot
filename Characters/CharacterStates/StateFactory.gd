# state_factory.gd

class_name StateFactory

var states

func _init():
	states = {
		GlobalVariables.CharacterState.GROUND: GroundState,
		GlobalVariables.CharacterState.AIR: AirState, 
		GlobalVariables.CharacterState.ATTACKAIR: AttackAirState,
		GlobalVariables.CharacterState.SHIELD: ShieldState, 
		GlobalVariables.CharacterState.GRAB: GrabState, 
		GlobalVariables.CharacterState.ATTACKGROUND: AttackGroundState,
		GlobalVariables.CharacterState.CROUCH: CrouchState,
		GlobalVariables.CharacterState.SHIELDSTUN: ShieldStunState,
		GlobalVariables.CharacterState.SHIELDBREAK: ShieldBreakState, 
		GlobalVariables.CharacterState.ROLL: RollState,
		GlobalVariables.CharacterState.SPOTDODGE: SpotDodgeState,
		GlobalVariables.CharacterState.EDGE: EdgeState,
		GlobalVariables.CharacterState.EDGEGETUP: EdgeGetUpState,
		GlobalVariables.CharacterState.INGRAB: InGrabState, 
		GlobalVariables.CharacterState.HITSTUNAIR: HitStunAirState, 
		GlobalVariables.CharacterState.HITSTUNGROUND: HitStunGroundState,
		GlobalVariables.CharacterState.GETUP: GetUpState,
		GlobalVariables.CharacterState.TECHAIR: AirTechState, 
		GlobalVariables.CharacterState.TECHGROUND: GroundTechState,
		GlobalVariables.CharacterState.AIRDODGE: AirDodgeState,
		GlobalVariables.CharacterState.HELPLESS: HelplessState,
		GlobalVariables.CharacterState.REBOUND: ReboundState,
		GlobalVariables.CharacterState.SPECIALAIR: SpecialAir, 
		GlobalVariables.CharacterState.SPECIALGROUND: SpecialGround, 
		GlobalVariables.CharacterState.COUNTER: CounterState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
