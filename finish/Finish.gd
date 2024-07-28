extends Node2D

func _on_area_2d_area_entered(area:Area2D):
	var parent = area.get_parent();
	if (parent.is_in_group("player")):
		print("FINISHED");
		#TODO: finish stuff
