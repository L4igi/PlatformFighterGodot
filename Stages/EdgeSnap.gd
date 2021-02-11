extends Area2D

var edgeSnapDirection = "left" 
var character_on_edge = []
onready var centerStage = get_parent()

func _ready():
	yield(get_tree().root, "ready")
	for character in GlobalVariables.charactersInGame: 
		character.connect("character_state_changed", self, "_on_character_state_change")


func _on_EdgeSnap_area_entered(area):
	if area.is_in_group("CollisionArea"):
		var edgeCharacter = area.get_parent().get_parent()
		if !character_on_edge.has(area.get_parent().get_parent()):
			character_on_edge.append(area.get_parent().get_parent())
		edgeCharacter.snap_edge(self)



func _on_EdgeSnap_area_exited(area):
	character_on_edge.erase(area.get_parent().get_parent())


func _on_character_state_change(character, currentState):
	if character_on_edge.has(character):
		if character.snappedEdge == null && currentState == character.CharacterState.AIR\
		&& character.global_position.y >= centerStage.checkYPoint.global_position.y: 
			character.snap_edge(self)
