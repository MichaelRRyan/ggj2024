extends Entity

@export var speed : float = 300.0
@export var acceleration : float = 300.0
@export var jump_velocity : float = -400.0
@export var health : float = 10
var fall_strength : int = 0;
@export var fall_dmg_thershold : float = 20.0
@export var fall_dmg_ratio : float = 1.0
var target
var is_interacting : bool = false
var has_task : bool = false
var has_target : bool
var target_x : float = 0.0
var target_x_diff : float = 0.0
var direction : int = 0
var rng = RandomNumberGenerator.new()
var random_number = 0.0

@onready var harvest_timer = $TimerHarvest

@onready var _pickup_component : PickupComponent = get_node("PickupComponent")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		fall_strength += 1
	
	if is_on_floor():
		if fall_strength >= 20.0:
			health -= (fall_strength - 20.0) / 10.0
			fall_strength = 0
		velocity.x *= _ground_friction
	else:
		velocity.x *= _air_friction
		
	print(has_target)
	
	if has_target:
		target_x_diff = get_global_position().x - target_x
		print(target_x_diff)
		if target_x_diff < 0.0:
			direction = 1
		else:
			direction = -1
	#else:
		#direction = 0

	if has_task && not has_target && not is_interacting:
		if random_number >= 0.0:
			direction = 1
		else:
			direction = -1

	if _pickup_component == null or not _pickup_component.is_held():
		velocity.x = clamp(velocity.x + direction * acceleration * delta, -speed, speed)

	move_and_slide()

func _on_view_body_entered(body):
	if not is_interacting:
		if body.is_in_group("tree"):
			target = body
			has_target = true
			has_task = true
			target_x = target.get_global_position().x
			print(target_x)


func _on_timer_idle_timeout():
	if not has_target:
		if not is_interacting:
			has_task = not has_task
			random_number = rng.randf_range(-1.0, 1.0)


func _on_interact_range_body_entered(_body):
	if has_target:
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
	has_target = false
	pass # Replace with function body.
