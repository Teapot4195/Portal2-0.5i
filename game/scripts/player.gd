extends CharacterBody3D

signal fire_orange(player);
signal fire_blue(player);

var speed;
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
const jump_height := 1.0; # How high the player can jump under Earth's gravity
const mouse_sensitivity = 0.01;
const walk_speed = 5;
const run_speed = 9;
const player_full_height = 2;
const player_crouch_height = 1.2;
const height_difference = player_full_height - player_crouch_height;
const crouch_speed_modifier = 0.8;
const reach_distance = 3;
const ideal_hold_distance = 2;
const max_hold_mass = 15; # the max mass the player can hold
const held_obj_impulse_scale = 6.0;
const held_obj_rot_impulse_scale = PI/256;

@onready var collider = $CollisionShape3D;
@onready var head = $Head;
@onready var camera = $Head/Camera3D;

var held_object = null;
var held_object_parent;
var held_object_collision_mask;
var held_object_collision_layer;

# Called when the node enters the scene tree for the first time.
func _ready(): 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _unhandled_input(event):
	if (event is InputEventMouseMotion): # camera look when mouse
		head.rotate_y(-event.relative.x * mouse_sensitivity); # the xs and the ys are the wrong way around because rotation is weird
		camera.rotate_x(-event.relative.y * mouse_sensitivity);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)); # can't look further than directly up/down

func hold_object(object):
	if (object as RigidBody3D).mass > max_hold_mass or !(object as Node).get_meta("isProp", false): return; # if too heavy OR not prop, don't pickup
	held_object = object;
	held_object.sleeping = true; # so we can't get a concurrent exception if this function is called outside the physics loop (which may sometimes be a different thread)
	held_object_parent = object.get_parent();
	object.reparent(self);
	held_object.gravity_scale = 0;
	held_object_collision_mask = held_object.collision_mask;
	held_object_collision_layer = held_object.collision_layer;
	held_object.collision_layer = 0;
	held_object.collision_mask = 1; # the shift is to make it clear that this is a mask and that I want the first index
	held_object.sleeping = false; # re-enable object

func is_held(object): # keep in mind, this doesn't do a null check
	return object == held_object;

func drop_object():
	if (held_object == null): return;
	held_object.sleeping = true; # so we can't get a concurrent exception if this function is called outside the physics loop (which may sometimes be a different thread)
	held_object.reparent(held_object_parent);
	held_object.gravity_scale = 1; # TODO add a force rather than resetting the gravity scale to fix that weird bug
	held_object.collision_mask = held_object_collision_mask;
	held_object.collision_layer = held_object_collision_layer;
	held_object.sleeping = false; # re-enable object
	held_object = null;

# finds the smallest angle between two angles
func find_angle_difference(angleA, angleB):
	var t = abs(angleB - angleA); # find the difference in angle
	t = fmod(t + PI,2 * PI)-PI; # if t was bigger than half a circle, then the other direction is faster. also if t was more than a full circle than it was redundantly big.
	t *= sign(angleB-angleA); # fix dir
	return t;

func _physics_process(delta):
	# move held item towards desired distance
	if (held_object != null): # TODO if collding, stop impulse in collide direction
		var cam_rot = head.rotation + camera.rotation;
		
		var desired_position = camera.position + Vector3(-ideal_hold_distance*sin(cam_rot.y), 
														  ideal_hold_distance*sin(cam_rot.x),
														 -ideal_hold_distance*cos(cam_rot.y)); 
		
		var distance = desired_position.distance_to(held_object.position);
		if (held_object.position.length() > reach_distance): # if too far away TODO this might not work through portals. Maybe also check the through-portal distance for both portals and use this maths on the smallest distance
			drop_object();
		else:
			var dir = (desired_position - held_object.position).normalized(); #find the direction of travel
			var desired_impulse = dir * clamp(distance * held_obj_impulse_scale, 0, 12); # Get good velocity for obj # TODO use bezier interpolate rather than clamp for smoothness
			#held_object.position = desired_position; # for debug
			(held_object as RigidBody3D).linear_velocity = Vector3.ZERO; # it's usually bad to set this directly as it may also be set by RigidBody, but in this specific case it's fine, since we don't want it affected by RigidBody
			(held_object as RigidBody3D).apply_impulse(desired_impulse);
			
			# cam_rot is the desired rotation
			#var obj_rot = held_object.rotation; # TODO use dir from player rather than supposed camera dir
			#var rot_dir = Vector3(find_angle_difference(obj_rot.x, cam_rot.x),
			#					  find_angle_difference(obj_rot.y, cam_rot.y),
			#					  find_angle_difference(obj_rot.z, cam_rot.z)).normalized(); # this might be better if I submit to quaternion weirdness
			
			#var desired_torque_impulse = rot_dir;
			held_object.rotation = Vector3.ZERO;
			held_object.rotation.y = self.global_position.direction_to(held_object.global_position).x; # I was going to do something fancy but this seems to work perfectly
			Hud.extra_text = held_object.rotation.y
			#(held_object as RigidBody3D).apply_torque_impulse(desired_torque_impulse);
	
	if (Input.is_action_just_pressed("fire_blue")): fire_blue.emit(self); # fire portals
	if (Input.is_action_just_pressed("fire_orange")): fire_orange.emit(self);
	
	if (Input.is_action_just_pressed("interact")):
		if (held_object != null):
			# Currently holding a prop, put it down
			drop_object();

		else:
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
	
	if (Input.is_action_pressed("crouch")): # TODO maybe sliding, maybe wall-running, maybe vaulting
		(collider.shape as CapsuleShape3D).height = player_crouch_height; # scale size
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
	
	var movDir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	var movVel = (head.transform.basis * Vector3(movDir.x, 0, movDir.y)).normalized()*speed; # update velocity based on speed and change in time, convert to vec3, then multiply by player rotation
	var newVel = Vector3(velocity.x, 0, velocity.z).slerp(movVel, min(1, speed/(4*velocity.length()+0.05))); # rotate in motion direction. The faster you're going, the harder it is to change direction. Plus some number fiddling to get it to work with slerp (i.e. make it output in range 0-1)
	velocity.x = newVel.x; # apply dir change
	velocity.z = newVel.z;
	
	move_and_slide() # process velocity

func jump(): 
	velocity.y += sqrt(2*9.81*jump_height);
	position.y += 0.002; # sometimes the player would stay colliding after 1 physics tick, causing them to get double the velocity they should. Teleporting them by a small value stops that.
