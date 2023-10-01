extends CharacterBody3D

signal fire_orange(player); # not implemented yet
signal fire_blue(player);

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
const reach_distance = 2;
const ideal_hold_distance = 2;
const max_hold_mass = 15; # the max mass the player can hold

@onready var collider = $CollisionShape3D;
@onready var head = $Head;
@onready var camera = $Head/Camera3D;

var held_object = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event):
	if (event is InputEventMouseMotion): # camera look when mouse
		head.rotate_y(-event.relative.x * mouse_sensitivity); # the xs and the ys are the wrong way around because rotation is weird
		camera.rotate_x(-event.relative.y * mouse_sensitivity);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)); # can't look further than directly up/down

 # TODO if too heavy, don't pick up 
func hold_object(object):
	held_object = object;
	held_object.sleeping = true; # gotta disable the object while messing with it
	object.get_parent().remove_child(object);
	self.add_child(object);
	held_object.sleeping = false; # re-enable object

func is_held(object): # keep in mind, this doesn't do a null check
	return object == held_object;

func drop_object():
	if (held_object == null): return;
	held_object.sleeping = true; # gotta disable the object while messing with it
	self.remove_child(held_object);
	self.get_parent().add_child(held_object);
	held_object.sleeping = false;
	held_object = null; # re-enable object

func _physics_process(delta): # TODO center and spin object when hold
	# move held item towards desired distance
	if (held_object != null):
		var desired_position = head.transform.basis * Vector3(0, 0, ideal_hold_distance); # TODO different acceleration based on difference in pos
		var dir = (desired_position - held_object.position).normalized(); #find the direction of travel
		var desired_impulse = dir * desired_position.distance_to(held_object.position) / 8; # Get good velocity for obj
		
	
	if (Input.is_action_just_pressed("fire_blue")): fire_blue.emit(self);
	if (Input.is_action_just_pressed("fire_orange")): fire_orange.emit(self);
	
	if (Input.is_action_just_pressed("interact")): # TODO check if prop. Will be solved when we stop player picking up heavy objects
		if (held_object != null):
			held_object.get_parent().remove_child(held_object);
		
		var space_state = get_world_3d().direct_space_state # get the space
		var mousepos = get_viewport().get_mouse_position(); # if moving, it may not be in the exact center of the screen
		
		var origin = camera.project_ray_origin(mousepos); # ray start pos
		var end = origin + camera.project_ray_normal(mousepos) * reach_distance; # ray end pos
		var query = PhysicsRayQueryParameters3D.create(origin, end); # cast ray
		query.exclude = [collider]; # the ray starts in the player's collider, but we don't want it to hit that so it needs to be exhempt
		
		
		var result = space_state.intersect_ray(query); # find out whether it hit anything
		if (result.get("collider") != null): # to stop null error if there's nothing to pick up
			hold_object(result.get("collider"));
	
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
