extends Node2D

func _on_play_button_pressed():
	get_tree().get_root().get_node("top").startGame();