extends CanvasLayer

class_name HUD

@onready var timer : Timer = $Timer
@onready var minutesText = $MinutesText
@onready var secondsText = $SecondsText
@onready var millisecondsText = $MillisecondsText
var elapsedTime = 0;

func _ready():
	timer.timeout.connect(on_timer_timeout);

func on_timer_timeout():
	elapsedTime += timer.wait_time;
	var minutes = int(elapsedTime / 60);
	var seconds = int(elapsedTime) % 60;
	var milliseconds = int((elapsedTime - int(elapsedTime)) * 1000);

	minutesText.text = "%02d" % [minutes];
	secondsText.text = "%02d" % [seconds];
	millisecondsText.text = "%03d" % [milliseconds];

func stopTime():
	timer.stop();
	StatsTracker.totalRunTime = elapsedTime;