extends Node2D

@export var menuScene : PackedScene;
@export var finishScene : PackedScene;
@export var gameScene : PackedScene;
var currentScene;

func _ready():
	var menu = menuScene.instantiate();
	currentScene = menu;
	add_child(menu);

func startGame():
	StatsTracker.totalRunTime = 0;
	switchToScene(gameScene);

func restartGame():
	StatsTracker.totalRunTime = 0;
	var nodes = get_tree().get_nodes_in_group("positionNodes")
	for node in nodes:
		if node:
			node.remove_from_group("positionNodes")
			node.queue_free()
	var playerNodes = get_tree().get_nodes_in_group("player")
	for node in playerNodes:
		if node:
			node.remove_from_group("player")
			node.queue_free()

	switchToScene(gameScene);

func switchToMenu():
	switchToScene(menuScene);

func switchToFinish():
	switchToScene(finishScene);

func switchToScene(scene : PackedScene):
	currentScene.queue_free();
	currentScene = null;
	call_deferred("loadNewScene", scene);

func loadNewScene(scene : PackedScene):
	var newScene = scene.instantiate();
	currentScene = newScene;
	add_child(newScene);
