extends Node2D

@export var hud : HUD

func _on_area_2d_area_entered(area:Area2D):
	var parent = area.get_parent();
	if (parent.is_in_group("player")):
		#well aren't we lazy today
		hud.stopTime();
		get_tree().get_root().get_node("top").switchToFinish();
