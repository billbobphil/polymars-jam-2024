extends Node2D

@export var warpTravelSpeed = 1200;
@export var warpExit : WarpExit;


func _on_area_2d_area_entered(area:Area2D):
	var parent = area.get_parent();

	if (parent.is_in_group("player")):
		var player = parent as Player;
		player.warpToPoint(warpExit, warpTravelSpeed);