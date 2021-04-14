extends Area2D

var solidGround = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ObjectAboveArea_body_entered(body):
	if body.is_in_group("Character"):
		print("ey")
		body.abovePlatGround = solidGround


func _on_ObjectAboveArea_body_exited(body):
	body.abovePlatGround = null
