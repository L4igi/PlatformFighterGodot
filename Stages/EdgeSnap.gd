extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_EdgeSnap_body_entered(body):
	if body.is_in_group("Character"):
		body.set_collision_mask_bit(1,false)
		body.snap_edge(self.global_position)
