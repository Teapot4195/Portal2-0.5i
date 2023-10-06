extends Node3D

@onready var BluePortal_Hitbox: Node3D = $BluePortal;
@onready var OrangePortal_Hitbox: Node3D = $OrangePortal;
@onready var Player_target: CharacterBody3D = $Player;

var Blue_Portal_target: Vector3;
var Orange_Portal_target: Vector3;

var in_box: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# TODO: refactor position data to only update when portal fire signal is emit.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Blue_Portal_target = BluePortal_Hitbox.position;
	Orange_Portal_target = OrangePortal_Hitbox.global_position;


func _blue_portal_entered(body):
	print(Orange_Portal_target)
	print(body.global_position)
	in_box = true;
	body.global_position = Orange_Portal_target;
	print(body.global_position)


func _blue_portal_exited(body):
	in_box = false;


func _orange_portal_entered(body):
	in_box = true;
	Player_target.global_position = Blue_Portal_target;


func _orange_portal_exited(body):
	in_box = false;
