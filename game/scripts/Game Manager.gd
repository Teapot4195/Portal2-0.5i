extends Container

var GameScene = preload("res://dev/aperture_test_lab.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Game start button pressed
func _on_button_pressed():
	get_tree().change_scene_to_file("res://dev/aperture_test_lab.tscn")
