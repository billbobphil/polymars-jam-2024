extends Node2D

@export var maxScale : float = 1.5;
@export var minScale : float = 0.5;
@export var scaleSpeed : float = 0.5;
@export var scaleDirection : int = 1;
@onready var obstacleToScale = $Obstacle;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scaleDirection == 1:
		obstacleToScale.scale += Vector2(scaleSpeed, scaleSpeed) * delta;
		if obstacleToScale.scale.x >= maxScale:
			scaleDirection = -1;
	elif scaleDirection == -1:
		obstacleToScale.scale -= Vector2(scaleSpeed, scaleSpeed) * delta;
		if obstacleToScale.scale.x <= minScale:
			scaleDirection = 1;
