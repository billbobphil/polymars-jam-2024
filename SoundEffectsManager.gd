extends Node2D

@export var buttonHover : AudioStreamPlayer
@export var buttonClick : AudioStreamPlayer
@export var getHit : AudioStreamPlayer
@export var collectOverheat : AudioStreamPlayer
@export var goIntoOverheat : AudioStreamPlayer
@export var breakEffect : AudioStreamPlayer
@export var warp : AudioStreamPlayer
@export var clickPositionNode : AudioStreamPlayer
@export var endOverheat : AudioStreamPlayer
@export var getCheckpoint : AudioStreamPlayer

func playSound(sound : AudioStreamPlayer):
	sound.play()
