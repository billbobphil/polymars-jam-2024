extends Node

class_name Player

@export_category("Movement Variables")
@export var travelSpeed: float;

var selectedNode: PositionNode;
var nodeToTravelTo: PositionNode;
var isTravelling: bool = false;
var currentTarget;
var isInvulnerable: bool = false;
var isInCutScene: bool = false;
var currentCheckpoint : PositionNode;
@export var startingCheckpoint : PositionNode;

@onready var camera : Camera2D = $Camera2D;
@onready var overheatButton : Button = $CanvasLayer/OverheatButton;
@export var requiredOverheatCollections : int = 3;
var currentOverheatCollections : int = 0;
var overheatAvailable : bool = false;
@export var overheatSeconds : float = 5;
var cameraInitialZoom : float = 1.25;
var cameraOverheatZoom : float = 1;
var playerInitialSpeed;
@export var playerSpeedMultiplier : float = 2;
var isOverheatActive : bool = false;
var overheatTimer : float = 0;
var zoomOutTime : float = .5;
var zoomInTime : float = .5;

func _ready():
	playerInitialSpeed = travelSpeed;
	currentCheckpoint = startingCheckpoint;
	overheatButton.disabled = true;

func _process(delta):

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
			if(nodeToTravelTo.isCheckpoint):
				currentCheckpoint = nodeToTravelTo;
				#TODO: some sort of checkpoint celebration
			isTravelling = false;
			nodeToTravelTo = null;

func overheat():
	if(overheatAvailable):
		currentOverheatCollections = 0;
		overheatTimer = 0;
		isOverheatActive = true;
		overheatButton.disabled = true;

func moveToNode(node: PositionNode):
	nodeToTravelTo = node;
	isTravelling = true;

func _on_area_2d_area_entered(area: Area2D):
	
	var parent = area.get_parent();

	if (parent.is_in_group("obstacles")):
		print("Player hit");
		isTravelling = false;
		nodeToTravelTo = null;
		endOverheat();
		self.global_position = currentCheckpoint.global_position;
		#TODO: pzazz
		# if (SoundEffectPlayer.onHitEffect != null):
		# 	SoundEffectPlayer.onHitEffect.play();
		return ;
	
	if (parent.is_in_group("overheat_collectible")):
		if(currentOverheatCollections >= requiredOverheatCollections):
			return;
		parent.queue_free();
		print("Overheat collected");
		currentOverheatCollections += 1;
		print("current overheats: ", currentOverheatCollections);
		if(currentOverheatCollections >= requiredOverheatCollections):
			overheatAvailable = true;
			overheatButton.disabled = false;

func endOverheat():
	isOverheatActive = false;	
	overheatTimer = 0;
	travelSpeed = playerInitialSpeed;
	camera.zoom.x = cameraInitialZoom;
	camera.zoom.y = cameraInitialZoom;
