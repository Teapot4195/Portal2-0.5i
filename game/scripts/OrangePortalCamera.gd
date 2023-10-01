extends Camera3D

@onready var BPortal: Node3D = owner.get_node("BluePortal")
@onready var OPortal: Node3D = owner.get_node("OrangePortal")
@onready var Player: CharacterBody3D = owner.get_node("Player")
@onready var PlayerHead: Node3D = Player.get_node("Head")
@onready var PlayerCamera: Camera3D = PlayerHead.get_node("Camera3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = Player.position + BPortal.position - OPortal.position
	
	self.rotation.x = PlayerCamera.rotation.x
	self.rotation.y = PlayerHead.rotation.y
