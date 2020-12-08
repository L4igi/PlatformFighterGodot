extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_EdgeSnap_area_entered(area):
	print(area.name)
	if area.is_in_group("CollisionArea"):
		var edgeCharacter = area.get_parent().get_parent()
#		body.set_collision_mask_bit(1,false)
		edgeCharacter.snap_edge(self.global_position)
