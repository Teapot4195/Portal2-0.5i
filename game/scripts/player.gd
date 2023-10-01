extends CharacterBody3D

var speed;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
const jump_height := 1.2; # How high the player can jump under Earth's gravity
const jump_time := 0.85; # How long a jump takes under Earth's gravity (assuming floor height is constant)
const mouse_sensitivity = 0.01;
const walk_speed = 5;
const run_speed = 9;
const player_full_height = 2;
const player_crouch_height = 1.2;
const height_difference = player_full_height - player_crouch_height;
const crouch_speed_modifier = 0.8;

@onready var collider = $CollisionShape3D;
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


func _physics_process(delta):
	if (Input.is_action_pressed("run")): speed = run_speed;
	else: speed = walk_speed;
	
	if (Input.is_action_pressed("crouch")): # TODO decrease speed while crouching, maybe sliding, maybe wall-running, vaulting
		(collider.shape as CapsuleShape3D).height = player_crouch_height; # scale size with 
		speed = walk_speed * crouch_speed_modifier; # can multiply every tick because it's set every tick
	else:
		(collider.shape as CapsuleShape3D).height = player_full_height;
	
	if (Input.is_action_just_pressed("crouch")): # when you crouch your legs don't move up, but scaling is from center so we need to compensate
		collider.position.y -= height_difference / 2;# half bc scales from center
		camera.position.y -= height_difference / 2;
	
	if (Input.is_action_just_released("crouch")): # when you crouch your legs don't move up, but scaling is from center so we need to compensate
		collider.position.y += height_difference / 2;# half bc scales from center
		camera.position.y += height_difference / 2;
	
	if(not is_on_floor()): # gravity
		velocity.y -= gravity * delta;
	
	elif (Input.is_action_pressed("jump")):
		jump();
	# TODO this should be if on floor
	var dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	var movVel = (head.transform.basis * Vector3(dir.x, 0, dir.y)).normalized()*speed; # update velocity based on speed and change in time, convert to vec3, then multiply by player rotation
	var newVel = Vector3(velocity.x, 0, velocity.z).slerp(movVel, min(1, speed/(4*velocity.length()+0.05))); # rotate in motion direction. The faster you're going, the harder it is to change direction. Plus some number fiddling to get it to work with slerp (i.e. make it output in range 0-1)
	velocity.x = newVel.x; # apply dir change
	velocity.z = newVel.z; 
	
	#if is_on_floor():# TODO implement floor friction coefficient. the default coeff is 0.9
	#	velocity.x = sign(velocity.x)*max(abs(velocity.x) - 0.9*gravity*delta,0);
	#	velocity.z = sign(velocity.z)*max(abs(velocity.z) - 0.9*gravity*delta,0);
	
	move_and_slide() # process velocity

func jump():
	velocity.y -= (jump_height / jump_time) - (0.5*9.81*jump_time);
