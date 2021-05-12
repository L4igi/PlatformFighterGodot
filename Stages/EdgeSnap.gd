extends Area2D

var edgeSnapDirection = "left" 
var character_on_edge = []
onready var centerStage = get_parent()

func _ready():
	yield(get_tree().root, "ready")
	for character in GlobalVariables.charactersInGame: 
		character.connect("character_state_changed", self, "_on_character_state_change")

func _on_EdgeSnap_area_entered(area):
	if area.is_in_group("EdgeGrabArea"):
		var edgeCharacter = area.get_parent()
		if !character_on_edge.has(edgeCharacter):
			for character in character_on_edge:
				character.state.on_push_off_edge()
			character_on_edge.append(edgeCharacter)
		edgeCharacter.snap_edge(self)

func _on_edgeCharacter_invincibility_timeout(character):
	if character_on_edge.size() > 1:
		if character_on_edge.back() != character:
			character.state.on_push_off_edge()

func _on_EdgeSnap_area_exited(area):
	character_on_edge.erase(area.get_parent())


func _on_character_state_change(character, currentState):
	pass
#	if character_on_edge.has(character) && character.currentState != GlobalVariables.CharacterState.EDGE:
#		if edgeSnapDirection == "left" && character.state.get_input_direction_x() > 0: 
#			character.snap_edge(self)
#		elif edgeSnapDirection == "right" && character.state.get_input_direction_x() < 0: 
#			character.snap_edge(self)
