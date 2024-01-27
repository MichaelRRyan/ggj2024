extends Entity

@export var speed : float = 300.0
@export var acceleration : float = 100.0
@export var jump_velocity : float = -400.0
@export var health : float = 10
var fall_strength : int = 0;
@export var fall_dmg_thershold : float = 20.0
@export var fall_dmg_ratio : float = 1.0
var has_axe : bool = false
var is_moving : bool = true
var has_target : bool = false
var target_x : float = 0.0
var target_x_diff : float = 0.0
var direction : int = 0

@onready var _pickup_component : PickupComponent = get_node("PickupComponent")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		fall_strength += 1
	
	if is_on_floor():
		if fall_strength >= 20:
			health -= (fall_strength - 20) / 10
			fall_strength = 0
		velocity.x *= _ground_friction
	else:
		velocity.x *= _air_friction
		
	if has_target:
		target_x_diff = get_global_position().x - target_x
		if target_x_diff < 0.0:
			direction = 1
		else:
			direction = -1
	else:
		direction = 0

	if _pickup_component == null or not _pickup_component.is_held():
		velocity.x = clamp(velocity.x + direction * acceleration * delta, -speed, speed)

	move_and_slide()

func _on_view_body_entered(body):
	if body.is_in_group("tree"):
		has_target = true
		target_x = body.get_global_position().x
