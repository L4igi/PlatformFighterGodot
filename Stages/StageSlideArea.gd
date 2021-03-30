extends Area2D

var centerStage

# Called when the node enters the scene tree for the first time.
func _ready():
	centerStage = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_SlideArea_body_entered(body):
	if body.is_in_group("Character"):
		body.stageSlideCollider = centerStage


func _on_SlideArea_body_exited(body):
	if body.is_in_group("Character"):
		body.stageSlideCollider = null
