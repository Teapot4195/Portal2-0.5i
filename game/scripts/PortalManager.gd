extends Node3D

@onready var BluePortal_Hitbox: Node3D = $BluePortal/Area3D;
@onready var OrangePortal_Hitbox: Node3D = $OrangePortal/Area3D;
@onready var Player_target: CharacterBody3D = $Player;

@onready var blue_subview = $BluePortal/SubViewport;
@onready var blue_mesh = $BluePortal/MeshInstance3D;

var Blue_Portal_target: Vector3;
var Orange_Portal_target: Vector3;

var in_box_blue: bool = false;
var in_box_orange: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body. 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# TODO: refactor position data to only update when portal fire signal is emit.
func _physics_process(delta):
	Blue_Portal_target = BluePortal_Hitbox.global_position;
	Orange_Portal_target = OrangePortal_Hitbox.global_position;


func _blue_portal_entered(body):
	if in_box_orange:
		return
	in_box_blue = true;
	# TODO: This is a little borked, you fall a little bit every time you go through the portal
	body.global_position = Orange_Portal_target;


func _blue_portal_exited(body):
	in_box_blue = false;


func _orange_portal_entered(body):
	if in_box_blue:
		return
	in_box_orange = true;
	Player_target.global_position = Blue_Portal_target;


func _orange_portal_exited(body):
	in_box_orange = false;
