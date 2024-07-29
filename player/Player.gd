extends Node

class_name Player

@export_category("Movement Variables")
@export var travelSpeed: float;

var selectedNode;
var nodeToTravelTo;
var isTravelling: bool = false;
var currentTarget;
var isInvulnerable: bool = false;
var isInCutScene: bool = false;
var currentCheckpoint : PositionNode;
@export var startingCheckpoint : PositionNode;

@onready var camera : Camera2D = $Camera2D;
@onready var overheatChargeLabel : Node2D = $CanvasLayer/OverheatChargingHolder;
@onready var overheatLabel : Node2D = $CanvasLayer/OverheatLabelHolder;
@onready var overheatBar : ProgressBar = $CanvasLayer/ProgressBar;
@export var requiredOverheatCollections : int = 3;
var currentOverheatCollections : int = 0;
var overheatAvailable : bool = false;
@export var overheatSeconds : float = 5;
var cameraInitialZoom : float = 1;
var cameraOverheatZoom : float = .75;
var playerInitialSpeed;
@export var playerSpeedMultiplier : float = 2;
var isOverheatActive : bool = false;
var overheatTimer : float = 0;
var zoomOutTime : float = .5;
var zoomInTime : float = .5;
var isWarping : bool = false;
var allowOverheat : bool = true;
var overheatAlreadyStartedEnding : bool = false;

func _ready():
	playerInitialSpeed = travelSpeed;
	currentCheckpoint = startingCheckpoint;
	currentCheckpoint.markCheckpointActive();

func _process(delta):

	if(Input.is_action_just_pressed("restart")):
		get_tree().get_root().get_node("top").restartGame();

	if(Input.is_action_just_pressed("overheat")):
		overheat();

	if(isOverheatActive):
		overheatTimer += delta;

		if(overheatTimer < zoomOutTime):
			var lerpFactor = overheatTimer/zoomOutTime;
			camera.zoom.x = lerp(cameraInitialZoom, cameraOverheatZoom, lerpFactor);
			camera.zoom.y = lerp(cameraInitialZoom, cameraOverheatZoom, lerpFactor);
			travelSpeed = lerp(playerInitialSpeed, playerInitialSpeed * playerSpeedMultiplier, lerpFactor);

		if(overheatTimer > (overheatSeconds - zoomInTime)):
			var lerpFactor = (overheatTimer - (overheatSeconds - zoomInTime)) / zoomInTime
			travelSpeed = lerp(playerInitialSpeed * playerSpeedMultiplier, playerInitialSpeed, lerpFactor);
			camera.zoom.x = lerp(cameraOverheatZoom, cameraInitialZoom, lerpFactor);
			camera.zoom.y = lerp(cameraOverheatZoom, cameraInitialZoom, lerpFactor);
			if(!overheatAlreadyStartedEnding):
				overheatAlreadyStartedEnding = true;
				SoundEffects.playSound(SoundEffects.endOverheat);

		if(overheatTimer >= overheatSeconds):
			endOverheat();

	if (isTravelling):
		var direction: Vector2 = (nodeToTravelTo.global_position - self.global_position).normalized();
		self.global_position += direction * travelSpeed * delta;
		# var angle: float = direction.angle();
		# sprite.rotation = angle + PI / 2;
		if (self.global_position.distance_to(nodeToTravelTo.global_position) <= 3):
			if(nodeToTravelTo is PositionNode && nodeToTravelTo.isCheckpoint):
				currentCheckpoint.markCheckpointInactive();
				currentCheckpoint = nodeToTravelTo;
				currentCheckpoint.markCheckpointActive();
				SoundEffects.playSound(SoundEffects.getCheckpoint);
			isTravelling = false;
			nodeToTravelTo = null;

func overheat():
	if(overheatAvailable && allowOverheat):
		currentOverheatCollections = 0;
		overheatTimer = 0;
		isOverheatActive = true;
		overheatLabel.visible = false;
		overheatChargeLabel.visible = true;
		overheatBar.value = 0;
		SoundEffects.playSound(SoundEffects.goIntoOverheat);
		overheatAlreadyStartedEnding = false;

func moveToNode(node):
	if(isWarping):
		return;
	SoundEffects.playSound(SoundEffects.clickPositionNode);
	nodeToTravelTo = node;
	isTravelling = true;

func _on_area_2d_area_entered(area: Area2D):
	
	var parent = area.get_parent();

	if (parent.is_in_group("obstacles")):
		getHit();
		return ;

	if (parent.is_in_group("breakables")):
		if(isOverheatActive):
			parent.queue_free();
			SoundEffects.playSound(SoundEffects.breakEffect);
		else:
			getHit();
		return;

	if(parent.is_in_group("maxOverheatNodes")):
		currentOverheatCollections = requiredOverheatCollections;
		SoundEffects.playSound(SoundEffects.collectOverheat);
		overheatBar.value = 100;
		makeOverheatAvailable();
		return;
	
	if (parent.is_in_group("overheat_collectible")):
		if(currentOverheatCollections >= requiredOverheatCollections):
			return;
		parent.queue_free();
		print("Overheat collected");
		currentOverheatCollections += 1;
		SoundEffects.playSound(SoundEffects.collectOverheat);
		overheatBar.value = (float(currentOverheatCollections) / float(requiredOverheatCollections)) * 100;
		print("current overheats: ", currentOverheatCollections);
		if(currentOverheatCollections >= requiredOverheatCollections):
			makeOverheatAvailable();
		return;

func makeOverheatAvailable():
	overheatAvailable = true;
	overheatLabel.visible = true;
	overheatChargeLabel.visible = false;

func getHit():
	print("Player hit");
	isTravelling = false;
	nodeToTravelTo = null;
	SoundEffects.playSound(SoundEffects.getHit);
	endOverheat();
	self.global_position = currentCheckpoint.global_position;

func endOverheat():
	isOverheatActive = false;	
	overheatTimer = 0;
	travelSpeed = playerInitialSpeed;
	camera.zoom.x = cameraInitialZoom;
	camera.zoom.y = cameraInitialZoom;
	overheatAlreadyStartedEnding = false;


func warpToPoint(node : WarpExit, warpSpeed):
	travelSpeed = warpSpeed;
	moveToNode(node);
	isWarping = true;
	allowOverheat = false;
	SoundEffects.playSound(SoundEffects.warp);

func endWarp():
	travelSpeed = playerInitialSpeed;
	isWarping = false;
	allowOverheat = true;
