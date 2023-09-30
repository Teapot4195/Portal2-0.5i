extends CharacterBody3D

var speed := 5;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
const jump_height := 1.2; # How high the player can jump under Earth's gravity
const jump_time := 0.85; # How long a jump takes under Earth's gravity (assuming floor height is constant)
const mouse_sensitivity = 0.01;

@onready var head = $Head;
@onready var camera = $Head/Camera3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		head.rotate_y(-event.relative.x * mouse_sensitivity);
		camera.rotate_x(-event.relative.y * mouse_sensitivity);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(not is_on_floor()): # gravity
		velocity.y -= gravity * delta;
		
	elif (Input.is_action_pressed("jump")):
		jump();
	
	var dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	velocity += (head.transform.basis * Vector3(dir.x, 0, dir.y)).normalized() * speed * delta; # update velocity based on speed and change in time, convert to vec3, then multiply by player rotation
	
	if (dir == Vector2.ZERO and is_on_floor()):
		velocity = Vector3(0, velocity.y, 0);
	
	move_and_slide() # process velocity

func jump():
	velocity.y -= (jump_height / jump_time) - (0.5*9.81*jump_time);
