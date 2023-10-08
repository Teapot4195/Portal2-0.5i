extends Control

@onready var main_scene: Node3D = $"/root/player_test"; # This only handles the player_test scene currently!

#Hud information displays
@onready var state: Label = $State;
static var extra_text = "";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = main_scene.get_node("Player");
	state.set_text("Velocity: " + str(player.get_velocity()) + "\n" +
				   "Position: " + str(player.global_position)
	+"\n"+str(extra_text));
	pass
