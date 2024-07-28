extends Node2D

@onready var yourTimeValue = $CanvasLayer/YourTimeValue;

func _ready():
	yourTimeValue.text = parseScoreToTime(StatsTracker.totalRunTime);

func parseScoreToTime(score: int):
	var minutes = int(score / 60);
	var seconds = int(score) % 60;
	var milliseconds = int((score - int(score)) * 1000);
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds];

func _on_menu_button_pressed():
	get_tree().get_root().get_node("top").switchToMenu();
