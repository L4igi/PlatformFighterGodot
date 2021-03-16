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
			character_on_edge.append(edgeCharacter)
		edgeCharacter.snap_edge(self)


func _on_EdgeSnap_area_exited(area):
	character_on_edge.erase(area.get_parent())


func _on_character_state_change(character, currentState):
	pass
#	if character_on_edge.has(character) && character.currentState != character.CharacterState.EDGE:
#		if edgeSnapDirection == "left" && character.get_input_direction_x() > 0: 
#			character.snap_edge(self)
#		elif edgeSnapDirection == "right" && character.get_input_direction_x() < 0: 
#			character.snap_edge(self)
