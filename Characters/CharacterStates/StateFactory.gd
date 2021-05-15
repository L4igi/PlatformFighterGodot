# state_factory.gd

class_name StateFactory

var states

func _init():
	states = {
		Globals.CharacterState.GROUND: GroundState,
		Globals.CharacterState.AIR: AirState, 
		Globals.CharacterState.ATTACKAIR: AttackAirState,
		Globals.CharacterState.SHIELD: ShieldState, 
		Globals.CharacterState.GRAB: GrabState, 
		Globals.CharacterState.ATTACKGROUND: AttackGroundState,
		Globals.CharacterState.CROUCH: CrouchState,
		Globals.CharacterState.SHIELDSTUN: ShieldStunState,
		Globals.CharacterState.SHIELDBREAK: ShieldBreakState, 
		Globals.CharacterState.ROLL: RollState,
		Globals.CharacterState.SPOTDODGE: SpotDodgeState,
		Globals.CharacterState.EDGE: EdgeState,
		Globals.CharacterState.EDGEGETUP: EdgeGetUpState,
		Globals.CharacterState.INGRAB: InGrabState, 
		Globals.CharacterState.HITSTUNAIR: HitStunAirState, 
		Globals.CharacterState.HITSTUNGROUND: HitStunGroundState,
		Globals.CharacterState.GETUP: GetUpState,
		Globals.CharacterState.TECHAIR: AirTechState, 
		Globals.CharacterState.TECHGROUND: GroundTechState,
		Globals.CharacterState.AIRDODGE: AirDodgeState,
		Globals.CharacterState.HELPLESS: HelplessState,
		Globals.CharacterState.REBOUND: ReboundState,
		Globals.CharacterState.SPECIALAIR: SpecialAir, 
		Globals.CharacterState.SPECIALGROUND: SpecialGround, 
		Globals.CharacterState.COUNTER: CounterState, 
		Globals.CharacterState.RESPAWN: RespawnState, 
		Globals.CharacterState.GAMESTART: GameStartState, 
		Globals.CharacterState.DEFEAT: DefeatState, 
		Globals.CharacterState.GAMEOVER: GameOverState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
