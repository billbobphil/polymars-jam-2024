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
# @onready var sprite: Sprite2D = $Sprite;

func _ready():
	pass ;

func _process(delta):
	if (isTravelling):
		var direction: Vector2 = (nodeToTravelTo.global_position - self.global_position).normalized();
		self.global_position += direction * travelSpeed * delta;
		# var angle: float = direction.angle();
		# sprite.rotation = angle + PI / 2;
		if (self.global_position.distance_to(nodeToTravelTo.global_position) <= 3):
			isTravelling = false;
			nodeToTravelTo = null;

func moveToNode(node: PositionNode):
	nodeToTravelTo = node;
	isTravelling = true;

func _on_area_2d_area_entered(area: Area2D):
	
	var parent = area.get_parent();
	pass;
	if (parent.is_in_group("obstacles")):
		print("Player hit");
		# if (SoundEffectPlayer.onHitEffect != null):
		# 	SoundEffectPlayer.onHitEffect.play();
		return ;

	# if (parent.is_in_group("pointsPickup")):
	# 	parent.queue_free();
	# 	print("Points picked up");
	# 	PointsManager.addPoints(100);
	# 	if (SoundEffectPlayer.pointsPickupEffect != null):
	# 		SoundEffectPlayer.pointsPickupEffect.play();
	# 	return ;
