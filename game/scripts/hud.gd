extends Control

var player: Node3D;

#Hud information displays
@onready var state: Label = $State;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		var PlayerPathA = "/root/Aperture Test Lab/PortalPair/Player";
		var PlayerPathB = "/root/player_test/Player";
		if get_tree().root.has_node(PlayerPathA):
			player = get_tree().root.get_node(PlayerPathA);
		if get_tree().root.has_node(PlayerPathB):
			player = get_tree().root.get_node(PlayerPathB);
	else:
		state.set_text("Velocity: " + str(player.get_velocity()) + "\n" +
					   "Position: " + str(player.global_position)
		)
	pass
