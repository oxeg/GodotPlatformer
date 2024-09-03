extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 5
@export var mouse_sensitivity = 1000
@export var jump_strength = 7

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer
@onready var platform = preload("res://objects/platform.tscn")

# Functions

func _physics_process(delta):
	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	# Animation when landing
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()

# Handle animation(s)
func handle_effects():
	
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation.play("walk", 0.5)
			particles_trail.emitting = true
			sound_footsteps.stream_paused = false
		else:
			animation.play("idle", 0.5)
	else:
		animation.play("jump", 0.5)

# Handle movement input
func handle_controls(delta):
	# Jumping
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			Audio.play("res://sounds/jump.ogg")
		
		if jump_double:
			gravity = -jump_strength
			
			jump_double = false
			model.scale = Vector3(0.5, 1.5, 0.5)
			
		if(jump_single): jump()
	
	# Movement
	var applied_velocity: Vector3
	var move_forward = Input.get_axis("move_back", "move_forward")
	applied_velocity += transform.basis.z * move_forward * movement_speed
	
	var move_sideways = Input.get_axis("move_right", "move_left")
	applied_velocity += transform.basis.x * move_sideways * movement_speed
	
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Spawn platform
	if Input.is_action_just_pressed("spawn_platform"):
		print_debug("spawning platform")
		var newPlatform = platform.instantiate()
		newPlatform.transform.origin = transform.origin
		get_parent().add_child(newPlatform)


# Mouse Look
func _input(event):
	if not Input.is_action_pressed("mouse_look_activated"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		
		$CameraCenter.rotation.x += event.relative.y / mouse_sensitivity

# Handle gravity
func handle_gravity(delta):
	
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping
func jump():
	
	gravity = -jump_strength
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false;
	jump_double = true;

# Collecting coins
func collect_coin():
	
	coins += 1
	
	coin_collected.emit(coins)
