extends Node

func _on_mouse_entered():
	SoundEffects.playSound(SoundEffects.buttonHover)


func _on_pressed():
	SoundEffects.playSound(SoundEffects.buttonClick)
