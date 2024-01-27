extends CharacterBody2D


@export var speed : float = 300.0
@export var jump_velocity : float = -400.0
@export var health : float = 10
var fall_strength : int = 0;
@export var fall_dmg_thershold : float = 20.0
@export var fall_dmg_ratio : float = 1.0
var target
var is_interacting : bool = false
var has_task : bool = false
var has_axe : bool = false
var is_moving : bool = true
var has_target : bool = false
var target_x : float = 0.0
var target_x_diff : float = 0.0
var direction : int = 0
var rng = RandomNumberGenerator.new()
var random_number = 0.0

@onready var harvest_timer = $TimerHarvest


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		fall_strength += 1
		print(fall_strength)
	
	if is_on_floor():
		if fall_strength >= 20:
			health -= (fall_strength - 20) / 10
			print(health)
			fall_strength = 0

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_velocity

	if has_target:
		target_x_diff = get_global_position().x - target_x
		if target_x_diff < 0.0:
			direction = 1
		else:
			direction = -1
	else:
		direction = 0
		
	if has_task && not has_target && not is_interacting:
		if random_number >= 0.0:
			direction = 1
		else:
			direction = -1
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	#if has_target:
	velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _on_view_body_entered(body):
	if not is_interacting:
		if body.is_in_group("tree"):
			target = body
			has_target = true
			has_task = true
			target_x = body.get_global_position().x
			print(target_x)


func _on_timer_idle_timeout():
	if not has_target:
		if not is_interacting:
			has_task = not has_task
			random_number = rng.randf_range(-1.0, 1.0)


func _on_interact_range_body_entered(body):
	if has_target:
		has_target = false
		is_interacting = true
		has_task = true
		direction = 0
		harvest_timer.start(3)


func _on_timer_harvest_timeout():
	target.chop()
	target.queue_free()
	harvest_timer.stop()
	is_interacting = false
	has_task = false
	pass # Replace with function body.
