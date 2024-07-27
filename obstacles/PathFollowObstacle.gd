extends Node2D

@export var pathSpeed = 50;
@onready var pathFollow = $Path2D/PathFollow2D;
@export var startingProgress : float = 0;

func _ready():
	pathFollow.progress_ratio = startingProgress;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pathFollow.progress += delta * pathSpeed;