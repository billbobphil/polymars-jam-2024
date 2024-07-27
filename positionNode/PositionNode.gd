extends Node2D

class_name PositionNode

signal position_node_selected

@onready var sprite = $Sprite2D;
@export var activeColor : Color;
@export var inactiveColor : Color;
@export var isStartingNode : bool = false;
@export var isEndingNode : bool = false;
@export var isCheckpoint : bool = false;

func _ready():
	markAsInactive();

func _on_mouse_click(_viewport:Node, event:InputEvent, _shape_idx:int):
	if(event is InputEventMouseButton && event.button_index == 1 && event.pressed):
		position_node_selected.emit(self);
	
func markAsActive():
	sprite.modulate = activeColor;

func markAsInactive():
	sprite.modulate = inactiveColor;
