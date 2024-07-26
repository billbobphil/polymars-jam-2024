extends Node

var positionNodes : Array[PositionNode] = []
var player : Player;
var lastNodeSelected : PositionNode;

func _ready():
	var nodes = get_tree().get_nodes_in_group("positionNodes");
	for node in nodes:
		var positionNode = node as PositionNode
		positionNodes.append(positionNode)

	for positionNode in positionNodes:
		positionNode.position_node_selected.connect(on_node_selected);
		pass;
	
	#So we can run scenes without a player without errors
	var playerNodes = get_tree().get_nodes_in_group("player");
	if(playerNodes.size() > 0):
		player = playerNodes[0] as Player;	

func on_node_selected(selectedNode):
	player.moveToNode(selectedNode);
	selectedNode.markAsActive();
	if(lastNodeSelected == null):
		lastNodeSelected = selectedNode;
	else:
		#modify the node from beforehand, then mark the current selected one as the one last selected
		if(lastNodeSelected != selectedNode):
			lastNodeSelected.markAsInactive();
			lastNodeSelected = selectedNode;
