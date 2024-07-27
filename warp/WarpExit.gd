extends Node2D

class_name WarpExit

func _on_area_2d_area_entered(area:Area2D):
	var parent = area.get_parent();

	if (parent.is_in_group("player")):
		var player = parent as Player;
		player.endWarp();
