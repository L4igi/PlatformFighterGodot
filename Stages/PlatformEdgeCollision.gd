extends Node

var platform 

func _ready():
	platform = get_parent()


func _on_EdgeCollisionAreaRight_body_entered(body):
	if body.is_in_group("Character"):
		platform.add_collding_edge_body(body)


func _on_EdgeCollisionAreaRight_body_exited(body):
	if body.is_in_group("Character"):
		platform.remove_colliding_edge_body(body)
		


func _on_EdgeCollisionAreaLeft_body_entered(body):
	if body.is_in_group("Character"):
		platform.add_collding_edge_body(body)


func _on_EdgeCollisionAreaLeft_body_exited(body):
	if body.is_in_group("Character"):
		platform.remove_colliding_edge_body(body)
