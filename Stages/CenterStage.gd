extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft


# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(445,-30))
	stopAreaLeft.set_position(Vector2(-445,-30))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
