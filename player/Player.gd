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
@onready var overheatLabel : Label = $CanvasLayer/OverheatLabel;
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

func _ready():
	playerInitialSpeed = travelSpeed;
	currentCheckpoint = startingCheckpoint;

func _process(delta):

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

		if(overheatTimer >= overheatSeconds):
			endOverheat();

	if (isTravelling):
		var direction: Vector2 = (nodeToTravelTo.global_position - self.global_position).normalized();
		self.global_position += direction * travelSpeed * delta;
		# var angle: float = direction.angle();
		# sprite.rotation = angle + PI / 2;
		if (self.global_position.distance_to(nodeToTravelTo.global_position) <= 3):
			if(nodeToTravelTo is PositionNode):
				if(nodeToTravelTo.isCheckpoint):
					currentCheckpoint = nodeToTravelTo;
				#TODO: some sort of checkpoint celebration
			isTravelling = false;
			nodeToTravelTo = null;

func overheat():
	if(overheatAvailable && allowOverheat):
		currentOverheatCollections = 0;
		overheatTimer = 0;
		isOverheatActive = true;
		overheatLabel.visible = false;

func moveToNode(node):
	if(isWarping):
		return;
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
		else:
			getHit();
		return;

	if(parent.is_in_group("maxOverheatNodes")):
		currentOverheatCollections = requiredOverheatCollections;
		makeOverheatAvailable();
		return;
	
	if (parent.is_in_group("overheat_collectible")):
		if(currentOverheatCollections >= requiredOverheatCollections):
			return;
		parent.queue_free();
		print("Overheat collected");
		currentOverheatCollections += 1;
		print("current overheats: ", currentOverheatCollections);
		if(currentOverheatCollections >= requiredOverheatCollections):
			makeOverheatAvailable();
		return;

func makeOverheatAvailable():
	overheatAvailable = true;
	overheatLabel.visible = true;

func getHit():
	#TODO: make it fancy
	print("Player hit");
	isTravelling = false;
	nodeToTravelTo = null;
	endOverheat();
	self.global_position = currentCheckpoint.global_position;

func endOverheat():
	isOverheatActive = false;	
	overheatTimer = 0;
	travelSpeed = playerInitialSpeed;
	camera.zoom.x = cameraInitialZoom;
	camera.zoom.y = cameraInitialZoom;

func warpToPoint(node : WarpExit, warpSpeed):
	travelSpeed = warpSpeed;
	moveToNode(node);
	isWarping = true;
	allowOverheat = false;

func endWarp():
	travelSpeed = playerInitialSpeed;
	isWarping = false;
	allowOverheat = true;
